getNextTask = require '../lib/get_next_task'
CurrentTask = require './current_task'
RelativeTasks = require './relative_tasks'
Task = require '../models/task'
error_ = require 'lib/error'
{ startLoading, stopLoading } = require 'modules/general/plugins/behaviors'

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

  ui:
    homonymsCount: '.homonymsCount'
    relativesToggler: '.toggle-relatives .fa-chevron-down'

  behaviors:
    Loading: {}

  onShow: ->
    { task } = @options
    if _.isModel task then @showTask _.preq.resolve(task)
    else if task? then @showFromId task
    else @showNextTask()

  showFromId: (taskId)-> @showTask getTaskById(taskId)

  showNextTask: -> @showTask getNextTask()

  showTask: (taskModelPromise)->
    taskModelPromise
    .tap (model)-> model.waitForData
    .then (model)=>
      @currentTaskModel = model
      @currentTask.show new CurrentTask { model }
      @relativeTasks.show new RelativeTasks
        collection: model.suspect.mergeSuggestions
        currentTaskModel: model
      @updateRelativesCount model
      app.navigateFromModel model
      @focusOnControls()
    .catch app.Execute('show:error')

  focusOnControls: ->
    # Take focus so that we can listen for keydown events
    @$el.focus()

  events:
    'click .dismiss': 'dismiss'
    'click .merge': 'merge'
    'click .next': 'showNextTaskFromButton'
    'click .controls': 'toggleRelatives'
    'keydown': 'triggerActionByKey'

  dismiss: (e)->
    @action 'dismiss'
    e.stopPropagation()

  merge: (e)->
    @action 'merge'
    e.stopPropagation()

  action: (actionName)->
    startLoading.call @, ".#{actionName}"
    @currentTaskModel[actionName]()
    .tap stopLoading.bind @
    .then @showNextTask.bind(@)

  showNextTaskFromButton: (e)->
    startLoading.call @, '.next'
    @showNextTask()
    .tap stopLoading.bind @

    e?.stopPropagation()

  triggerActionByKey: (e)->
    # Prevent interpretting browser shortkeys such as Alt+D or Ctrl+R
    # as action keys
    if e.altKey or e.ctrlKey or e.metaKey then return

    switch e.key
      when 'd' then @dismiss()
      when 'm' then @merge()
      when 'n' then @showNextTaskFromButton()
      when 'r' then @toggleRelatives()
      else
        if /^\d+$/.test(e.key)
          @showRelativeFromIndex parseInt(e.key) - 1

  toggleRelatives: ->
    @relativeTasks.$el.slideToggle()
    @ui.relativesToggler.toggleClass 'toggled'

  showRelativeFromIndex: (index)->
    el = @relativeTasks.$el.find('.relative-task')[index]
    taskId = el?.attributes['data-task-id'].value
    if taskId? then @showFromId taskId

  updateRelativesCount: (task)->
    { mergeSuggestions: suggestions } = task.suspect
    currentSuggestionScore = task.get 'globalScore'
    highestSuggestionsScore = suggestions.getHighestScore task.id
    # Remove the current task from the count
    count = suggestions.length - 1
    if count is 0
      text = _.i18n 'has no homonym'
      risk = 'none'
      @ui.relativesToggler.css 'visibility', 'hidden'
    else
      text = _.i18n 'homonyms_count', { smart_count: count }
      @ui.relativesToggler.css 'visibility', null
      if currentSuggestionScore - highestSuggestionsScore < 10
        risk = 'high'
      else
        risk = 'medium'

    @ui.homonymsCount.text text
    @ui.homonymsCount.attr 'data-risk', risk

getTaskById = (id)->
  _.preq.get app.API.tasks.byIds(id)
  .get 'tasks'
  .then (tasks)->
    task = tasks[0]
    if task? then new Task task
    else throw error_.new 'not found', 404, { id }
