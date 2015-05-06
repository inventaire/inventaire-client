books_ = app.lib.books
wd_ = app.lib.wikidata
WikidataEntity = require './models/wikidata_entity'
IsbnEntity = require './models/isbn_entity'
InvEntity = require './models/inv_entity'
Entities = require './collections/entities'
AuthorLi = require './views/author_li'
EntityShow = require './views/entity_show'

module.exports =
  define: (Entities, app, Backbone, Marionette, $, _) ->
    EntitiesRouter = Marionette.AppRouter.extend
      appRoutes:
        'entity/:uri(/:label)(/)': 'showEntity'
        'entity/:uri(/:label)/add(/)': 'showAddEntity'

    app.addInitializer ->
      new EntitiesRouter
        controller: API

  initialize: ->
    setHandlers()
    window.Entities = Entities = new Entities
    Entities.data = require('./entities_data')(app, _, _.preq)
    # need to waitForData, to know if user is loggedIn
    # otherwise, followedList wont be initialized
    app.request('waitForData').then ->
      Entities.followed = require('./follow')(app)

API =
  showEntity: (uri, label, params, region)->
    region or= app.layout.main
    app.execute 'show:loader', {region: region}

    [prefix, id] = getPrefixId(uri)
    if prefix? and id?
      @getEntityView(prefix, id)
      .then (view)-> region.show(view)
      .catch (err)->
        _.error err, 'couldnt showEntity'
        app.execute 'show:404'
    else
      console.warn 'prefix or id missing at showEntity'

  getEntityView: (prefix, id)->
    return @getEntityModel(prefix, id)
    .then (entity)->
      switch wd_.type(entity)
        when 'human'
          new AuthorLi
            model: entity
            displayBooks: true
            wikipediaPreview: true
        else
          new EntityShow {model: entity}
    .catch (err)-> _.error err, 'catch at showEntity: getEntityView'

  getEntitiesModels: (prefix, ids)->
    try Model = getModelFromPrefix(prefix)
    catch err then return _.preq.reject(err)

    Entities.data.get(prefix, ids, 'collection')
    .then (data)->
      if data?
        models = data.map (el)->
          unless el? then return _.warn 'missing entity'
          model = new Model(el)
          Entities.add model
          return model
        return models
      else throw new Error('couldnt find entity at getEntitiesModels')
    .catch (err)-> _.error err, 'getEntitiesModels err'

  getEntityModel: (prefix, id)->
    @getEntitiesModels prefix, id
    .then (models)->
      if models?[0]? then return models[0]
      else throw new Error "entity model not found: #{prefix}:#{id}"
    .catch (err)-> _.error err, 'getEntityModel err  (#{prefix}:#{id})'

  showAddEntity: (uri)->
    [prefix, id] = getPrefixId(uri)
    if prefix? and id?
      @getEntityModel(prefix, id)
      .then (entity)-> app.execute 'show:item:creation:form', {entity: entity}
      .catch (err)-> _.error err, 'showAddEntity err'
    else console.warn "prefix or id missing at showAddEntity: uri = #{uri}"

  getEntityPublicItems: (uri)->
    _.preq.get app.API.items.publicByEntity(uri)


setHandlers = ->
  app.commands.setHandlers
    'show:entity': (uri, label, params, region)->
      API.showEntity(uri, label, params, region)
      path = "entity/#{uri}"
      path += "/#{label}"  if label?
      app.navigate path

    'show:entity:from:model': (model, params, region)->
      uri = model.get('uri')
      label = model.get('label') or model.get('title')
      if uri? and label?
        app.execute 'show:entity', uri, label, params, region
      else throw new Error 'couldnt show:entity:from:model'

  app.reqres.setHandlers
    'get:entity:model': (prefix, id)->
      [prefix, id] = getPrefixId(prefix, id)
      return API.getEntityModel(prefix, id)
    'get:entities:models': API.getEntitiesModels
    'save:entity:model': saveEntityModel
    'get:entity:public:items': API.getEntityPublicItems
    'get:entities:labels': getEntitiesLabels
    'create:entity': createEntity
    'get:entity:local:href': getEntityLocalHref
    'normalize:entity:uri': normalizeEntityUri

getEntitiesLabels = (Qids)->
  return Qids.map (Qid)-> Entities.byUri("wd:#{Qid}")?.get 'label'

getPrefixId = (prefix, id)->
  # resolving the polymorphic interface
  # accepts 'prefix', 'id' or 'prefix:id'
  # returns ['prefix', 'id']
  unless id? then [prefix, id] = prefix?.split ':'
  if prefix? and id? then return [prefix, id]
  else
    throw new Error "prefix and id not found for: #{prefix} / #{id}"

getModelFromPrefix = (prefix)->
  switch prefix
    when 'wd' then WikidataEntity
    when 'isbn' then IsbnEntity
    when 'inv' then InvEntity
    else throw new Error("prefix not implemented: #{prefix}")

saveEntityModel = (prefix, data)->
  if data?.id?
    Entities.data[prefix].local.save(data.id, data)
  else _.error arguments, 'couldnt save entity model'

createEntity = (data)->
  Entities.data.inv.local.post(data)
  .then (entityData)->
    _.type entityData, 'object'
    model = new InvEntity(entityData)
    Entities.add model
    return model

getEntityLocalHref = (domain, id, label)->
  # accept both domain, id or uri-style "#{domain}:#{id}"
  [domain, possibleId] = domain?.split(':')
  if possibleId? then [id, label] = [possibleId, id]

  if domain?.length > 0 and id?.length > 0
    href = "/entity/#{domain}:#{id}"
    if label?
      label = _.softEncodeURI(label)
      href += "/#{label}"
    return href
  else throw new Error "couldnt find EntityLocalHref: domain=#{domain}, id=#{id}, label=#{label}"

normalizeEntityUri = (prefix, id)->
  # accepts either a 'prefix:id' uri or 'prefix', 'id'
  # the polymorphic interface is resolved by getPrefixId
  [prefix, id] = getPrefixId(prefix, id)
  if prefix is 'isbn' then id = books_.normalizeIsbn(id)
  return "#{prefix}:#{id}"
