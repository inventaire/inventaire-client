export default {
  define () {
    const Router = Marionette.AppRouter.extend({
      appRoutes: {
        'feedback(/)(:id)(/)': 'showFeedbackTask',
        'tasks(/)(:id)(/)': 'showTask',
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
      return showLayout({ task })
    }
  },
  showFeedbackTask (task) {
    if (app.request('require:loggedIn', 'tasks')) {
      return showLayout({ task, type: 'feedback' })
    }
  }
}

const showLayout = async params => {
  const { default: TasksLayout } = await import('./views/tasks_layout')
  return app.layout.main.show(new TasksLayout(params))
}
