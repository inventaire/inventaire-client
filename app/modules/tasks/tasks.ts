import app from '#app/app'

export default {
  initialize () {
    const Router = Marionette.AppRouter.extend({
      appRoutes: {
        'tasks(/)(works)(/)': 'showWorksTask',
        'tasks(/)(humans)(/)': 'showHumansTask',
        'tasks(/)(:id)(/)': 'showTask',
      },
    })

    new Router({ controller })
  },
}

const controller = {
  showHumansTask (task) { controller.showTask(task, 'human') },
  showWorksTask (task) { controller.showTask(task, 'work') },
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
    props: { taskId, entitiesType }
  })
}
