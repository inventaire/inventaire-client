import app from '#app/app'

export default {
  initialize () {
    const Router = Marionette.AppRouter.extend({
      appRoutes: {
        'tasks(/)': 'showTasksDashboard',
        'tasks/delete/(:entitiesType)(/)': 'showDeleteTask',
        'tasks/merge/(:entitiesType)(/)': 'showMergeTask',
        'tasks/deduplicate/(:entitiesType)(/)': 'showDeduplicateTask',
        'tasks/none(/)': 'showNoTask',
        'tasks(/)(:id)(/)': 'showTask',
      },
    })

    new Router({ controller })
  },
}

const controller = {
  showDeleteTask (entitiesType) { showLayout({ type: 'delete', entitiesType }) },
  showMergeTask (entitiesType) { showLayout({ type: 'merge', entitiesType }) },
  showDeduplicateTask (entitiesType) { showLayout({ type: 'deduplicate', entitiesType }) },
  showTask (taskId) {
    if (app.request('require:dataadmin:access', 'tasks')) {
      return showLayout({ taskId })
    }
  },
  async showNoTask () {
    const { default: NoTask } = await import('./components/no_task.svelte')
    app.layout.showChildComponent('main', NoTask)
  },
  async showTasksDashboard () {
    if (app.request('require:dataadmin:access', 'tasks')) {
      const { default: TasksDashboard } = await import('./components/dashboard/tasks_dashboard.svelte')
      app.layout.showChildComponent('main', TasksDashboard, {})
    }
  },
}

const showLayout = async params => {
  const { entitiesType } = params
  if (entitiesType) {
    params.entitiesType = entitiesType.slice(0, -1)
  }
  const { default: TaskLayout } = await import('./components/task_layout.svelte')
  app.layout.showChildComponent('main', TaskLayout, {
    props: params,
  })
}
