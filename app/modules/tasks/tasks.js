export default {
  define () {
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
  async showTask (task) {
    if (app.request('require:loggedIn', 'tasks')) {
      const { default: TasksLayout } = await import('./views/tasks_layout')
      return app.layout.main.show(new TasksLayout({ task }))
    }
  }
}
