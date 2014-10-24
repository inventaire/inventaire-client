books = app.lib.books

module.exports =
  define: (Entities, app, Backbone, Marionette, $, _) ->
    EntitiesRouter = Marionette.AppRouter.extend
      appRoutes:
        'entity/search': 'showEntitiesSearchForm'
        'entity/:uri(/:label)(/)': 'showEntity'
        'entity/:uri(/:label)/add(/)': 'showAddEntity'

    app.addInitializer ->
      new EntitiesRouter
        controller: API

  initialize: ->
    setHandlers()
    @categories = categories

    Locals = app.Collection.Local

    window.Entities = Entities =
      wd: new Locals.WikidataEntities
      isbn: new Locals.NonWikidataEntities
      tmp:
        wd: new Locals.TmpWikidataEntities
        isbn: new Locals.TmpNonWikidataEntities

    collections = [ Entities.wd, Entities.isbn, Entities.tmp.wd, Entities.tmp.isbn ]

    Entities.byUri = (uri)->
      result = undefined
      collections.forEach (collection)->
        model = collection.byUri(uri)
        if model? then result = model
      return result

    Entities.hardReset = ->
      collections.forEach (collection)-> collection._reset()
      localStorage.clear()

    Entities.length = ->
      collections
      .map (el)-> el.length
      .reduce (a,b)-> a + b

    Entities.wd.getCachedEntity = API.getWikidataCachedEntity
    Entities.isbn.getCachedEntity = API.getIsbnCachedEntity

    Entities.fetched = true
    app.vent.trigger 'entities:ready'

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

  getEntityView: (prefix, id)->
    return @getEntityModel(prefix, id)
    .then (entity)->
      switch wd.type(entity)
        when 'human'
          new app.View.Entities.AuthorLi {model: entity, displayBooks: true}
        else
          # the view is named after Wikidata, waiting for
          # the possibility to merge those view
          new app.View.Entities.Wikidata {model: entity}
    .fail (err)-> _.log err, 'fail at showEntity: getEntityView'

  getEntityModel: (prefix, id)->
    unless prefix? and id? then throw 'missing prefix or id'
    entityPromise = @getCachedEntityPromise(prefix, id)
    if entityPromise then return entityPromise
    else
      switch prefix
        when 'wd'
          modelPromise = @getEntityModelFromWikidataId(id)
          collection = Entities.wd
        when 'isbn'
          modelPromise = @getEntityModelFromIsbn(id)
          collection = Entities.isbn
        else _.log [prefix, id], 'not implemented prefix, cant getEntityModel'

      return modelPromise.then (model)->
        if model?.has('title')
          return collection.create(model)
        else
          console.warn 'entity undefined or miss a title: discarded', 'model:', model, 'prefix:', prefix, 'id:', id

  getCachedEntityPromise: (prefix, id)->
    entity = @getCachedEntity(prefix, id)
    if entity?
      # console.log 'found cachedEntity', prefix, id, entity
      return $.Deferred().resolve(entity)
    else
      console.log 'not found cachedEntity', prefix, id
      return false

  getCachedEntity: (prefix, id)->
    # looking first in in-memory models
    entity = Entities.byUri("#{prefix}:#{id}")
    if entity? then return entity
    else
      # then in localStorage
      switch prefix
        when 'wd'
          data = @getWikidataCachedEntity(id)
          # only attributes are persisted so it needs to be re-modeled
          if data? then return Entities.wd.add(data)
        when 'isbn'
          data = @getIsbnCachedEntity(id)
          if data? then return Entities.isbn.add(data)
        else return

  getWikidataCachedEntity: (id)->
    Entities.wd.recoverDataById?(id) or Entities.tmp.wd.recoverDataById?(id)

  getIsbnCachedEntity: (id)->
    Entities.isbn.recoverDataById?(id) or Entities.tmp.isbn.recoverDataById?(id)

  getEntityModelFromWikidataId: (id)->
    # not looking for a specific WikidataEntity
    # as the upgrade will happen at Model initialization
    wd.getEntities(id, app.user.lang)
    .then (res)-> new app.Model.WikidataEntity res.entities[id]
    .fail (err)-> _.log err, 'getEntityModelFromWikidataId err'

  getEntityModelFromIsbn: (isbn)->
    books.getGoogleBooksDataFromIsbn(isbn)
    .then (res)->
      if res? then return new app.Model.NonWikidataEntity res
      else console.warn "couldnt getEntityModelFromIsbn for: #{isbn}"
    .fail (err)-> _.log err, 'getEntityModelFromIsbn err'

  showAddEntity: (uri)->
    [prefix, id] = getPrefixId(uri)
    if prefix? and id?
      @getEntityModel(prefix, id)
      .then (entity)-> app.execute 'show:item:creation:form', {entity: entity}
      .fail (err)-> _.log err, 'showAddEntity err'
      .done()
    else console.warn "prefix or id missing at showAddEntity: uri = #{uri}"

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


setHandlers = ->
  app.commands.setHandlers
    'show:entity': (uri, label, params, region)->
      API.showEntity(uri, label, params, region)
      path = "entity/#{uri}"
      path += "/#{label}"  if label?
      app.navigate path

    'show:entity:from:model': (model, params, region)->
      uri = model.get('uri')
      label = model.get('label')
      if uri? and label?
        app.execute 'show:entity', uri, label, params, region
      else throw new Error 'couldnt show:entity:from:model'

    'show:entity:search': ->
      API.showEntitiesSearchForm()
      app.navigate 'entity/search'

  app.reqres.setHandlers
    'get:entity:model': (uri)->
      [prefix, id] = getPrefixId(uri)
      return API.getEntityModel(prefix, id)
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
    icon: 'cube'

getPrefixId = (uri)->
  data = uri.split ':'
  if data.length is 1 and wd.isWikidataId(data)
    data = ['wd', data[0]]
  else if data.length is not 2
    throw new Error "prefix and id not found for: #{uri}"
  return data