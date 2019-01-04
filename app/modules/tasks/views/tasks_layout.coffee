getNextTask = require '../lib/get_next_task'
CurrentTask = require './current_task'
RelativeTasks = require './relative_tasks'
Task = require '../models/task'
error_ = require 'lib/error'
forms_ = require 'modules/general/lib/forms'
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
    AlertBox: {}
    Loading: {}

  onShow: ->
    { task } = @options
    if _.isModel task then @showTask _.preq.resolve(task)
    else if task? then @showFromId task
    else @showNextTask()

  showNextTask: (params = {})->
    { spinner } = params
    if spinner? then startLoading.call @, spinner
    @showTask getNextTask()
    .tap => if spinner? then stopLoading.call(@, spinner)

  showTask: (taskModelPromise)->
    taskModelPromise
    .then @showFromModel.bind(@)
    .catch app.Execute('show:error')

  showFromModel: (model)->
    @currentTaskModel = model
    state = model.get 'state'
    if state?
      err = error_.new 'this task has already been treated', 400, { model, state }
      return app.execute 'show:error:other', err, 'tasks_layout showFromModel'

    @_grabSuspectPromise = model.grabSuspect()

    Promise.all [
      @showCurrentTask model
      @showRelativeTasks model
    ]
    .catch app.Execute('show:error')

  showCurrentTask: (model)->
    Promise.all [
      @_grabSuspectPromise
      model.grabSuggestion()
    ]
    .then =>
      @currentTask.show new CurrentTask { model }
      app.navigateFromModel model
      @focusOnControls()

  showRelativeTasks: (model)->
    @_grabSuspectPromise
    .then model.getOtherSuggestions.bind(model)
    .then =>
      @relativeTasks.show new RelativeTasks
        collection: model.suspect.mergeSuggestions
        currentTaskModel: model
      @updateRelativesCount model

  showFromId: (id)-> @showTask getTaskById(id)

  focusOnControls: ->
    # Take focus so that we can listen for keydown events
    @$el.focus()

  events:
    'click .dismiss': 'dismiss'
    'click .merge': 'merge'
    'click .mergeAndDeduplicate': 'mergeAndDeduplicate'
    'click .next': 'showNextTaskFromButton'
    'click .controls': 'toggleRelatives'
    'keydown': 'triggerActionByKey'

  dismiss: (e)->
    @action 'dismiss'
    @showNextTask { spinner: '.dismiss' }
    e?.stopPropagation()

  merge: (e)->
    @action 'merge'
    @showNextTask { spinner: '.merge' }
    e?.stopPropagation()

  mergeAndDeduplicate: (e)->
    { suggestion } = @currentTaskModel

    @action 'merge'
    .delay 100
    .then -> app.execute 'show:deduplicate:sub:entities', suggestion, { openInNewTab: true }

    @showNextTask { spinner: '.mergeAndDeduplicate' }
    e?.stopPropagation()

  action: (actionName)->
    @currentTaskModel[actionName]()
    .catch @handleActionError.bind(@, @currentTaskModel)

  handleActionError: (actionTaskModel, err)->
    error_.complete err, '.alertWrapper', false
    forms_.catchAlert @, err
    @showFromModel actionTaskModel

  showNextTaskFromButton: (e)->
    @showNextTask { spinner: '.next' }
    e?.stopPropagation()

  triggerActionByKey: (e)->
    # Prevent interpretting browser shortkeys such as Alt+D or Ctrl+R
    # as action keys
    if e.altKey or e.ctrlKey or e.metaKey then return

    switch e.key
      when 'd' then @dismiss()
      when 'm' then @merge()
      when 'w' then @mergeAndDeduplicate()
      when 'n' then @showNextTaskFromButton()
      when 'r' then @toggleRelatives()
      else
        if /^\d+$/.test(e.key)
          @showRelativeFromIndex parseInt(e.key) - 1

  toggleRelatives: ->
    @$el.toggleClass 'wrapped-controls'
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
