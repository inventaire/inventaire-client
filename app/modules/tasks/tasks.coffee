TasksLayout = require './views/tasks_layout'

module.exports =
  define: (module, app, Backbone, Marionette, $, _)->
    Router = Marionette.AppRouter.extend
      appRoutes:
        'tasks(/)': 'showTasks'

    app.addInitializer -> new Router { controller: API }

API = showTasks: ->
    app.layout.main.show new TasksLayout
