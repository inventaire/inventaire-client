books = app.lib.books

module.exports =
  define: (Entities, app, Backbone, Marionette, $, _) ->
    EntitiesRouter = Marionette.AppRouter.extend
      appRoutes:
        'entity/search(?*queryString)(/)': 'showEntitiesSearchForm'
        'entity/:uri(/:label)(/)': 'showEntity'
        'entity/:uri(/:label)/add(/)': 'addEntity'

    app.addInitializer ->
      new EntitiesRouter
        controller: API

  initialize: ->
    initializeEntitiesSearchHandlers()
    @categories = categories

API =
  showEntity: (uri, label, params, region)->
    region ||= app.layout.main
    app.execute 'show:loader', region

    [prefix, id] = getPrefixId(uri)
    if prefix? and id?
      switch prefix
        when 'wd' then viewPromise = @getWikidataEntityView(id)
        when 'isbn' then viewPromise = @getIsbnEntityView(id)
        else _.log [prefix, id], 'not implemented prefix for showEntity'
    else console.warn 'prefix or id missing at showEntity'

    if viewPromise?
      viewPromise.then (view)-> region.show(view)
    else
      app.execute 'show:404'


  getWikidataEntityView: (id)->
    return @getEntityModelFromWikidataId(id)
    .then (entity)-> new app.View.Entities.Wikidata {model: entity}
    .fail (err)-> _.log err, 'fail at showEntity: getWikidataEntityView'

  getIsbnEntityView: (isbn)->
    return @getEntityModelFromIsbn(isbn)
    .then (entity)-> new app.View.Entities.Wikidata {model: entity}
    .fail (err)-> _.log err, 'fail at showEntity: getIsbnEntityView'





  addEntity: (uri)->
    [prefix, id] = getPrefixId(uri)
    if prefix? and id?
      switch prefix
        when 'wd' then entityPromise = @getEntityModelFromWikidataId(id)
        when 'isbn' then entityPromise = @getEntityModelFromIsbn(id)
        else _.log [prefix, id], 'not implemented prefix for addEntity'

      if entityPromise? then @showItemCreationForm(entityPromise)
      # else case already logged above

    else console.warn "prefix or id missing at addEntity: uri = #{uri}"

  showItemCreationForm: (entityPromise)->
    entityPromise
    .then (entity)-> app.execute 'show:item:creation:form', {entity: entity}
    .fail (err)-> _.log err, 'showItemCreationForm err'
    .done()

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