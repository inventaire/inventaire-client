import app from '#app/app'

export default {
  initialize () {
    const Router = Marionette.AppRouter.extend({
      appRoutes: {
        'tasks(/)': 'showTasksDashboard',
        'tasks(/)(collections)(/)': 'showCollectionTask',
        'tasks(/)(humans)(/)': 'showHumansTask',
        'tasks(/)(publishers)(/)': 'showPublisherTask',
        'tasks(/)(works)(/)': 'showWorksTask',
        'tasks(/)(serie)(/)': 'showSeriesTask',
        'tasks(/)(editions)(/)': 'showEditionsTask',
        'tasks(/)(:id)(/)': 'showTask',
      },
    })

    new Router({ controller })
  },
}

const controller = {
  showCollectionTask (_) { controller.showTask(_, 'collection') },
  showHumansTask (_) { controller.showTask(_, 'human') },
  showPublisherTask (_) { controller.showTask(_, 'publisher') },
  showWorksTask (_) { controller.showTask(_, 'work') },
  showSeriesTask (_) { controller.showTask(_, 'serie') },
  showEditionsTask (_) { controller.showTask(_, 'edition') },
  showTask (taskId, entitiesType) {
    if (app.request('require:dataadmin:access', 'tasks')) {
      return showLayout({ taskId, entitiesType })
    }
  },
  async showTasksDashboard () {
    const { default: TasksDashboard } = await import('./components/dashboard/tasks_dashboard.svelte')
    app.layout.showChildComponent('main', TasksDashboard, {})
  },
}

const showLayout = async params => {
  const { default: TaskLayout } = await import('./components/task_layout.svelte')
  const { taskId, entitiesType } = params
  app.layout.showChildComponent('main', TaskLayout, {
    props: { taskId, entitiesType },
  })
}
