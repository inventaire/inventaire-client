export default {
  define () {
    const Router = Marionette.AppRouter.extend({
      appRoutes: {
        'feedback(/)(:id)(/)': 'showWorksTask',
        'tasks(/)(:id)(/)': 'showHumansTask',
      }
    })

    app.addInitializer(() => new Router({ controller: API }))
  },

  initialize () {
    app.commands.setHandlers({
      'show:task': API.showHumansTask
    })
  }
}

const API = {
  showHumansTask (task) {
    if (app.request('require:loggedIn', 'tasks')) {
      return showLayout({ task })
    }
  },
  showWorksTask (task) {
    if (app.request('require:loggedIn', 'tasks')) {
      return showLayout({ task, entitiesType: 'works' })
    }
  }
}

const showLayout = async params => {
  const { default: TasksLayout } = await import('./views/tasks_layout')
  return app.layout.main.show(new TasksLayout(params))
}
