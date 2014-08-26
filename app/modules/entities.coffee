module.exports =
  define: (Entities, app, Backbone, Marionette, $, _) ->
    EntitiesRouter = Marionette.AppRouter.extend
      appRoutes:
        'entity/search?*queryString': 'showItemCreationForm'
        'entity/search': 'showItemCreationForm'
        'entity/:id/*label': 'showEntity'
        'entity/:id': 'showEntity'

    app.addInitializer ->
      new EntitiesRouter
        controller: API

  initialize: ->
    initializeEntitiesSearchHandlers()
    @categories = categories

API =
  listEntities: (options)-> _.log options, 'listEntities \o/'
  showEntity: (id)->
    app.layout.main.show new app.View.Behaviors.Loader
    wd.getEntities(id)
    .then (res)->
      if res.entities?[id]?
        entity = res.entities[id]
        _.log [id, res, entity], 'showEntity \o/'
        wd.rebaseClaimsValueToClaimsRoot(entity)
        model = new Backbone.Model entity
        wdEntity = new app.View.Entities.Wikidata {model: model}
        app.layout.main.show wdEntity
      else
        _.log [id, res], 'no entity?!?'
    .fail (err)-> _.log err, 'fail at showEntity'
    .done()

  showItemCreationForm: (queryString)->
    app.layout.item ||= new Object
    form = app.layout.item.creation = new app.View.ItemCreationForm
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
    'show:item:form:creation': ->
      API.showItemCreationForm()
      app.navigate 'entity/search'
    'show:item:form:edition': API.showItemEditionForm

categories =
  book:
    text: 'book'
    value: 'book'
    icon: 'book'
    entity: 'Q571'
  other:
    text: 'something else'
    value: 'other'
