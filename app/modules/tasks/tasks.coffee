TasksLayout = require './views/tasks_layout'

module.exports =
  define: (module, app, Backbone, Marionette, $, _)->
    Router = Marionette.AppRouter.extend
      appRoutes:
        'tasks(/)(:id)(/)': 'showTask'

    app.addInitializer -> new Router { controller: API }

  initialize: ->
    app.commands.setHandlers
      'show:task': API.showTask

API =
  showTask: (task)->
    if app.request 'require:loggedIn', 'tasks'
      app.layout.main.show new TasksLayout { task }
