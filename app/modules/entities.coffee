module.exports =
  define: (Entities, app, Backbone, Marionette, $, _) ->
    EntitiesRouter = Marionette.AppRouter.extend
      appRoutes:
        "entities(/search/:filter)": "listEntities"
        "entities/:id": "showEntity"


    app.on 'entities:list', (data)->
      app.navigate("entities/" + data)
      _.log data, 'entities data'
      API.listEntities(data)

    app.addInitializer ->
      new EntitiesRouter
        controller: API
API =
  listEntities: (options)-> _.log options, 'listEntities \o/'
  showEntity: (id)-> _.log id, 'showEntity \o/'