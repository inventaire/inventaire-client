import TasksLayout from './views/tasks_layout'

export default {
  define (module, app, Backbone, Marionette, $, _) {
    const Router = Marionette.AppRouter.extend({
      appRoutes: {
        'tasks(/)(:id)(/)': 'showTask'
      }
    })

    app.addInitializer(() => new Router({ controller: API }))
  },

  initialize () {
    app.commands.setHandlers({
      'show:task': API.showTask
    })
  }
}

const API = {
  showTask (task) {
    if (app.request('require:loggedIn', 'tasks')) {
      return app.layout.main.show(new TasksLayout({ task }))
    }
  }
}
