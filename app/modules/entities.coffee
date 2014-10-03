books = app.lib.books

module.exports =
  define: (Entities, app, Backbone, Marionette, $, _) ->
    EntitiesRouter = Marionette.AppRouter.extend
      appRoutes:
        'entity/search(?*queryString)(/)': 'showEntitiesSearchForm'
        'entity/:uri(/:label)(/)': 'showEntity'
        'entity/:uri(/:label)/add(/)': 'showAddEntity'

    app.addInitializer ->
      new EntitiesRouter
        controller: API

  initialize: ->
    initializeEntitiesSearchHandlers()
    @categories = categories
    window.Entities = new app.Collection.Entities
    _.log Entities.length, "Entities.length"

API =
  showEntity: (uri, label, params, region)->
    region ||= app.layout.main
    app.execute 'show:loader', {region: region}

    [prefix, id] = getPrefixId(uri)
    if prefix? and id?
      @getEntityView(prefix, id)
      .then (view)-> region.show(view)
      .fail (err)->
        _.log err, 'couldnt showEntity'
        app.execute 'show:404'
    else
      console.warn 'prefix or id missing at showEntity'


  showAddEntity: (uri)->
    [prefix, id] = getPrefixId(uri)
    if prefix? and id?
      @getEntityModel(prefix, id)
      .then (entity)-> app.execute 'show:item:creation:form', {entity: entity}
      .fail (err)-> _.log err, 'showAddEntity err'
      .done()
    else console.warn "prefix or id missing at showAddEntity: uri = #{uri}"

  getEntityView: (prefix, id)->
    return @getEntityModel(prefix, id)
    .then (entity)->
      # the view is named after Wikidata, waiting for
      # the possibility to merge those view
      new app.View.Entities.Wikidata {model: entity}
    .fail (err)-> _.log err, 'fail at showEntity: getEntityView'

  getEntityModel: (prefix, id)->
    entity = @cachedEntity("#{prefix}:#{id}")
    if entity then return entity
    else
      switch prefix
        when 'wd' then modelPromise = @getEntityModelFromWikidataId(id)
        when 'isbn' then modelPromise = @getEntityModelFromIsbn(id)
        else _.log [prefix, id], 'not implemented prefix, cant getEntityModel'

      return modelPromise.then (model)->
        if model?.has('title')
          Entities.create(model)
        else console.error 'entity undefined or miss a title: discarded', model

  cachedEntity: (uri)->
    entity = Entities.byUri(uri)
    if entity?
      _.log entity, 'entity: found cached entity'
      return $.Deferred().resolve(entity)
    else false

  getEntityModelFromWikidataId: (id)->
    wd.getEntities(id, app.user.lang)
    .then (res)-> new app.Model.WikidataEntity res.entities[id]
    .fail (err)-> _.log err, 'getEntityModelFromWikidataId err'

  getEntityModelFromIsbn: (isbn)->
    books.getGoogleBooksDataFromIsbn(isbn)
    .then (res)-> new app.Model.NonWikidataEntity res
    .fail (err)-> _.log err, 'getEntityModelFromIsbn err'

  showEntitiesSearchForm: (queryString)->
    app.layout.entities ||= new Object
    form = app.layout.entities.search = new app.View.Entities.Search
    app.layout.main.show form
    if queryString?
      query = _.parseQuery(queryString)
      if query.category?
        $("#step1 ##{query.category}").trigger('click')
        if query.search?
          $("#step2 input").val(query.search)
          $("#step2 .button").trigger('click')

  getEntityPublicItems: (uri)->
    return $.getJSON app.API.items.public(uri)
    .fail _.log


initializeEntitiesSearchHandlers = ->
  app.commands.setHandlers
    'show:entity': (uri, label, params, region)->
      API.showEntity(uri, label, params, region)
      path = "entity/#{uri}"
      path += "/#{label}"  if label?
      app.navigate path

    'show:entity:search': ->
      API.showEntitiesSearchForm()
      app.navigate 'entity/search'

  app.reqres.setHandlers
    'getEntityModelFromWikidataId': API.getEntityModelFromWikidataId
    'get:entity:public:items': API.getEntityPublicItems


categories =
  book:
    text: 'book'
    value: 'book'
    icon: 'book'
    entity: 'Q571'
  other:
    text: 'something else'
    value: 'other'

getPrefixId = (uri)->
  data = uri.split ':'
  if data.length is 1 and wd.isWikidataId(data)
    data = ['wd', data[0]]
  else if data.length is not 2
    throw new Error "prefix and id not found for: #{uri}"
  return _.log data, 'entities: prefix, id'