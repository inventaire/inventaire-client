module.exports =
  define: (module, app, Backbone, Marionette, $, _) ->
    ListingsRouter = Marionette.AppRouter.extend
      appRoutes:
        'listing/edit': 'bla'

    app.addInitializer ->
      new ListingsRouter
        controller: API

    app.commands.setHandlers
      'bla': API.bla


API =
  bla: -> _.log 'bla', 'bla'