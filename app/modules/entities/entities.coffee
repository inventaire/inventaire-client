books = app.lib.books
WikidataEntity = require './models/wikidata_entity'
IsbnEntity = require './models/isbn_entity'
InvEntity = require './models/inv_entity'
Entities = require './collections/entities'
AuthorLi = require './views/author_li'
EntityShow = require './views/entity_show'
wd = app.lib.wikidata

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
        _.log err, 'couldnt showEntity'
        app.execute 'show:404'
    else
      console.warn 'prefix or id missing at showEntity'

  getEntityView: (prefix, id)->
    return @getEntityModel(prefix, id)
    .then (entity)->
      switch wd.type(entity)
        when 'human'
          new AuthorLi
            model: entity
            displayBooks: true
            wikipediaPreview: true
        else
          new EntityShow {model: entity}
    .catch (err)-> _.log err, 'catch at showEntity: getEntityView'

  getEntitiesModels: (prefix, ids)->
    try Model = getModelFromPrefix(prefix)
    catch err then return _.preq.reject(err)

    Entities.data.get(prefix, ids, 'collection')
    .then (data)->
      if data?
        models = data.map (el)->
          model = new Model(el)
          Entities.add model
          return model
        return models
      else throw new Error('couldnt find entity at getEntitiesModels')
    .catch (err)-> _.log err, 'getEntitiesModels err'

  getEntityModel: (prefix, id)->
    @getEntitiesModels prefix, id
    .then (models)-> return models[0]
    .catch (err)-> _.log err, 'getEntityModel err'

  showAddEntity: (uri)->
    [prefix, id] = getPrefixId(uri)
    if prefix? and id?
      @getEntityModel(prefix, id)
      .then (entity)-> app.execute 'show:item:creation:form', {entity: entity}
      .catch (err)-> _.log err, 'showAddEntity err'
    else console.warn "prefix or id missing at showAddEntity: uri = #{uri}"

  getEntityPublicItems: (uri)->
    _.preq.get app.API.items.public(uri)


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
    'get:entity:model': (uri)->
      [prefix, id] = getPrefixId(uri)
      return API.getEntityModel(prefix, id)
    'get:entities:models': API.getEntitiesModels
    'save:entity:model': saveEntityModel
    'get:entity:public:items': API.getEntityPublicItems
    'get:entities:labels': getEntitiesLabels
    'create:entity': createEntity


getEntitiesLabels = (Qids)->
  return Qids.map (Qid)-> Entities.byUri("wd:#{Qid}")?.get 'label'

getPrefixId = (uri)->
  data = uri.split ':'
  if data.length is 1 and wd.isWikidataId(data)
    data = ['wd', data[0]]
  else if data.length is not 2
    throw new Error "prefix and id not found for: #{uri}"
  return data

getModelFromPrefix = (prefix)->
  switch prefix
    when 'wd' then return WikidataEntity
    when 'isbn' then return IsbnEntity
    when 'inv' then return InvEntity
    else throw new Error("prefix not implemented: #{prefix}")

saveEntityModel = (prefix, data)->
  Entities.data[prefix].local.save(data.id, data)

createEntity = (data)->
  Entities.data.inv.local.post(data)
  .then (entityData)->
    _.type entityData, 'object'
    model = new InvEntity(entityData)
    Entities.add model
    return model
