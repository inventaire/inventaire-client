import app from '#app/app'

export default {
  initialize () {
    const Router = Marionette.AppRouter.extend({
      appRoutes: {
        'tasks(/)': 'showTasksDashboard',
        'tasks/merge(/)': 'showTasksDashboard',
        'tasks/deduplicate(/)': 'showTasksDashboard',
        'tasks/none(/)': 'showTasksDashboard',
        'tasks/merge/:entitiesType(/)': 'showMergeTask',
        'tasks/deduplicate/:entitiesType(/)': 'showDeduplicateTask',
        'tasks/:id(/)': 'showTask',
      },
    })

    new Router({ controller })
  },
}

const controller = {
  showMergeTask (entitiesType) { controller.showTask(null, 'merge', entitiesType) },
  showDeduplicateTask (entitiesType) { controller.showTask(null, 'deduplicate', entitiesType) },
  showTask (taskId, type, entitiesType) {
    const singularEntitiesType = entitiesType.slice(0, -1)
    if (app.request('require:dataadmin:access', 'tasks')) {
      return showLayout({
        taskId,
        entitiesType: singularEntitiesType,
        type,
      })
    }
  },
  async showTasksDashboard () {
    if (app.request('require:dataadmin:access', 'tasks')) {
      const { default: TasksDashboard } = await import('./components/dashboard/tasks_dashboard.svelte')
      app.layout.showChildComponent('main', TasksDashboard, {})
    }
  },
}

const showLayout = async params => {
  const { default: TaskLayout } = await import('./components/task_layout.svelte')
  app.layout.showChildComponent('main', TaskLayout, {
    props: params,
  })
}
