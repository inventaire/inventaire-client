getNextTask = require '../lib/get_next_task'
CurrentTask = require './current_task'
Task = require '../models/task'

module.exports = Marionette.LayoutView.extend
  id: 'tasksLayout'
  attributes:
    # Allow the view to be focused by clicking on it, thus being able to listen
    # for keydown events
    tabindex: '0'

  template: require './templates/tasks_layout'
  regions:
    currentTask: '#currentTask'
    relativeTasks: '#relativeTasks'

  onShow: ->

    { taskId } = @options
    if taskId? then @showTask getTaskById(taskId)
    else @showNextTask()

  showNextTask: -> @showTask getNextTask()

  showTask: (taskModelPromise)->
    taskModelPromise
    .tap (model)-> model.waitForData
    .then (model)=>
      @currentTaskModel = model
      @currentTask.show new CurrentTask { model }
      app.navigateFromModel model
      @focusOnControls()

  focusOnControls: ->
    # Take focus so that we can listen for keydown events
    @$el.focus()

  events:
    'click .dismiss': 'dismiss'
    'click .merge': 'merge'
    'click .next': 'showNextTask'
    'keydown': 'triggerActionByKey'

  dismiss: ->
    @currentTaskModel.dismiss()
    .then @showNextTask.bind(@)

  merge: ->
    @currentTaskModel.merge()
    .then @showNextTask.bind(@)

  triggerActionByKey: (e)->
    switch e.key
      when 'd' then @dismiss()
      when 'm' then @merge()
      when 'n' then @showNextTask()

getTaskById = (id)->
  _.preq.get app.API.tasks.byIds(id)
  .get 'tasks'
  .then (tasks)-> new Task tasks[0]
