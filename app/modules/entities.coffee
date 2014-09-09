module.exports =
  define: (Entities, app, Backbone, Marionette, $, _) ->
    EntitiesRouter = Marionette.AppRouter.extend
      appRoutes:
        'entity/search?*queryString': 'showEntitiesSearchForm'
        'entity/search': 'showEntitiesSearchForm'
        'entity/:id': 'showEntity'
        'entity/:id/add': 'addEntity'
        'entity/:id/:label': 'showEntity'
        'entity/:id/:label/add': 'addEntity'

    app.addInitializer ->
      new EntitiesRouter
        controller: API

  initialize: ->
    initializeEntitiesSearchHandlers()
    @categories = categories

API =
  listEntities: (options)-> _.log options, 'listEntities \o/'
  showEntity: (id, label, region)->
    region ||= app.layout.main
    app.execute 'show:loader', region
    wd.getEntities(id, app.user.lang)
    .then (res)->
      if res.entities?[id]?
        _.log res, 'res'
        entity = new app.Model.WikidataEntity res.entities[id]
        wdEntity = new app.View.Entities.Wikidata {model: entity}
        region.show wdEntity
      else _.log [id, res], 'no entity?!?'
    .fail (err)-> _.log err, 'fail at showEntity'
    .done()

  addEntity: (id)->
    _.log id, 'addEntity'
    if wd.isWikidataId(id)
      @showItemCreationFormFromWikidataId id
    else _.log 'entity id not implemented yet or badly formatted'

  # showItemPersonalSettingsFromEntityURI: (uri)->
  #   [prefix, id] = uri.split ':'
  #   if prefix? and id?
  #     switch prefix
  #       when 'wd'
  #         @showItemCreationFormFromWikidataId(id)

  showItemCreationFormFromWikidataId: (id)->
    @getEntityModelFromWikidataId(id)
    .then (entity)->
      app.execute 'show:item:creation:form', {entity: entity}
    .fail (err)->
      _.log err, 'wd showItemCreationFormFromWikidataId err'
    .done()

  getEntityModelFromWikidataId: (id)->
    wd.getEntities(id)
    .then (res)->
      return new app.Model.WikidataEntity res.entities[id]
    .fail (err)->
      _.log err, 'getEntityModelFromWikidataId err'

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

  showItemEditionForm: (itemModel)->
    app.layout.item ||= new Object
    form = app.layout.item.edition = new app.View.ItemEditionForm {model: itemModel}
    app.layout.main.show form


initializeEntitiesSearchHandlers = ->
  app.commands.setHandlers
    'show:entity': API.showEntity
    'show:entity:search': ->
      API.showEntitiesSearchForm()
      app.navigate 'entity/search'
    'show:item:form:edition': (itemModel)->
      API.showItemEditionForm()
      path = "#{app.user.get('username')}/#{itemModel.id}/edit"
      app.navigate path

    'show:item:creation:form:fromEntity': API.showItemCreationFormFromEntity
    'show:item:personal:settings:fromEntityURI': API.showItemPersonalSettingsFromEntityURI

  app.reqres.setHandlers
    'getEntityModelFromWikidataId': API.getEntityModelFromWikidataId


categories =
  book:
    text: 'book'
    value: 'book'
    icon: 'book'
    entity: 'Q571'
  other:
    text: 'something else'
    value: 'other'

