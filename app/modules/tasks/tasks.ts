import app from '#app/app'

export default {
  initialize () {
    const Router = Marionette.AppRouter.extend({
      appRoutes: {
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
  showCollectionTask (task) { controller.showTask(task, 'collection') },
  showHumansTask (task) { controller.showTask(task, 'human') },
  showPublisherTask (task) { controller.showTask(task, 'publisher') },
  showWorksTask (task) { controller.showTask(task, 'work') },
  showSeriesTask (task) { controller.showTask(task, 'serie') },
  showEditionsTask (task) { controller.showTask(task, 'edition') },
  showTask (task, type) {
    if (app.request('require:dataadmin:access', 'tasks')) {
      return showLayout({ task, entitiesType: type })
    }
  },
}

const showLayout = async params => {
  const { default: TaskLayout } = await import('./components/task_layout.svelte')
  const { task: taskId, entitiesType } = params
  app.layout.showChildComponent('main', TaskLayout, {
    props: { taskId, entitiesType },
  })
}
