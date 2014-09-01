module.exports =
  define: (Entities, app, Backbone, Marionette, $, _) ->
    EntitiesRouter = Marionette.AppRouter.extend
      appRoutes:
        'entity/search?*queryString': 'showItemCreationForm'
        'entity/search': 'showItemCreationForm'
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
  showEntity: (id)->
    app.execute 'show:loader'
    wd.getEntities(id, app.user.lang)
    .then (res)->
      if res.entities?[id]?
        _.log res, 'res'
        entity = new app.Model.WikidataEntity res.entities[id]
        wdEntity = new app.View.Entities.Wikidata {model: entity}
        app.layout.main.show wdEntity
      else _.log [id, res], 'no entity?!?'
    .fail (err)-> _.log err, 'fail at showEntity'
    .done()

  addEntity: -> alert('add entity')

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

  showItemPersonalSettingsFromEntityModel: (entityModel)->
    if entityModel.toJSON
      entityData = entityModel.toJSON()
    else entityData = entityModel
    _.log entityData, 'entityData'
    entity =
      pathname: "/entity/#{entityData.id}"
      source: app.API.wikidata.uri(entityData.id)
      cachedData: entityData
    _.log [entity, entity.label], 'label?'
    entity.pathname += entity.label if entity.label?
    itemModel = new Backbone.Model
    itemModel.set('entity', entity)
    _.log itemModel, 'itemModel'
    app.execute 'show:item:personal:settings:fromItemModel', itemModel


  showItemPersonalSettingsFromEntityURI: (uri)->
    [prefix, id] = uri.split ':'
    if prefix? and id?
      switch prefix
        when 'wd'
          wd.getEntities(id)
          .then (res)->
            entityData = wd.parseEntityData(res, id)
            _.log app.entityData = entityData, 'entityData'
            app.execute 'show:item:personal:settings:fromEntityModel', entityData
          .fail (err)->
            _.log err, 'wd showItemPersonalSettingsFromEntityURI err'
          .done()



initializeEntitiesSearchHandlers = ->
  app.commands.setHandlers
    'show:item:form:creation': ->
      API.showItemCreationForm()
      app.navigate 'entity/search'
    'show:item:form:edition': (itemModel)->
      API.showItemEditionForm()
      path = "#{app.user.get('username')}/#{itemModel.id}/edit"
      app.navigate path

    'show:item:personal:settings:fromEntityModel': API.showItemPersonalSettingsFromEntityModel
    'show:item:personal:settings:fromEntityURI': API.showItemPersonalSettingsFromEntityURI


categories =
  book:
    text: 'book'
    value: 'book'
    icon: 'book'
    entity: 'Q571'
  other:
    text: 'something else'
    value: 'other'

