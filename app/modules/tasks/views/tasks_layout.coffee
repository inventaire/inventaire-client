TaskSuspect = require './task_suspect'

module.exports = Marionette.LayoutView.extend
  id: 'tasksLayout'
  template: require './templates/tasks_layout'

  regions:
    suspect: '#suspect'
    suggestions: '#suggestions'
    nav: '#nav'

  onShow: ->
    _.preq.get app.API.tasks.byScore
    .get 'tasks'
    .then _.Log('tasks')
    .then (tasks)=>
      @tasks = tasks
      task = tasks[0]
      { suspectUri } = task

      app.request 'get:entity:model', suspectUri
      .then (entity)=>
        view = new TaskSuspect { model: entity }
        @suspect.show view
