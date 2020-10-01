import getNextTask from '../lib/get_next_task'
import CurrentTask from './current_task'
import RelativeTasks from './relative_tasks'
import Task from '../models/task'
import error_ from 'lib/error'
import forms_ from 'modules/general/lib/forms'
import { startLoading, stopLoading } from 'modules/general/plugins/behaviors'
const previousTasks = []
let waitingForMerge = null

export default Marionette.LayoutView.extend({
  id: 'tasksLayout',
  attributes: {
    // Allow the view to be focused by clicking on it, thus being able to listen
    // for keydown events
    tabindex: '0'
  },

  template: require('./templates/tasks_layout'),
  regions: {
    currentTask: '#currentTask',
    relativeTasks: '#relativeTasks'
  },

  ui: {
    homonymsCount: '.homonymsCount',
    relativesToggler: '.toggle-relatives .fa-chevron-down'
  },

  behaviors: {
    AlertBox: {},
    Loading: {}
  },

  onShow () {
    const { task } = this.options
    if (_.isModel(task)) {
      return this.showTask(Promise.resolve(task))
    } else if (task != null) {
      return this.showFromId(task)
    } else { return this.showNextTask() }
  },

  showNextTask (params = {}) {
    const { spinner } = params
    if (spinner != null) { startLoading.call(this, spinner) }
    const offset = app.request('querystring:get', 'offset')
    return this.showTask(getNextTask({ previousTasks, offset, lastTaskModel: this.currentTaskModel }))
    .tap(() => { if (spinner != null) { return stopLoading.call(this, spinner) } })
  },

  showTask (taskModelPromise) {
    return taskModelPromise
    .then(this.showFromModel.bind(this))
    .catch(app.Execute('show:error'))
  },

  showFromModel (model) {
    this.previousTask = this.currentTaskModel
    this.currentTaskModel = model
    openDeduplicationLayoutIfDone(this.previousTask, this.currentTaskModel)

    const state = model.get('state')
    if (state != null) {
      const err = error_.new('this task has already been treated', 400, { model, state })
      return app.execute('show:error:other', err, 'tasks_layout showFromModel')
    }

    previousTasks.push(model.get('_id'))

    this._grabSuspectPromise = model.grabSuspect()

    return Promise.all([
      this.showCurrentTask(model),
      this.showRelativeTasks(model)
    ])
    .catch(app.Execute('show:error'))
  },

  showCurrentTask (model) {
    return Promise.all([
      this._grabSuspectPromise,
      model.grabSuggestion()
    ])
    .then(() => {
      this.currentTask.show(new CurrentTask({ model }))
      app.navigateFromModel(model)
      return this.focusOnControls()
    })
  },

  showRelativeTasks (model) {
    return this._grabSuspectPromise
    .then(model.getOtherSuggestions.bind(model))
    .then(() => {
      this.relativeTasks.show(new RelativeTasks({
        collection: model.suspect.mergeSuggestions,
        currentTaskModel: model
      })
      )
      return this.updateRelativesCount(model)
    })
  },

  showFromId (id) { return this.showTask(getTaskById(id)) },

  focusOnControls () {
    // Take focus so that we can listen for keydown events
    return this.$el.focus()
  },

  events: {
    'click .dismiss': 'dismiss',
    'click .merge': 'merge',
    'click .next': 'showNextTaskFromButton',
    'click .controls': 'toggleRelatives',
    keydown: 'triggerActionByKey'
  },

  dismiss (e) {
    this.action('dismiss')
    this.showNextTask({ spinner: '.dismiss' })
    return e?.stopPropagation()
  },

  merge (e) {
    waitingForMerge = this.action('merge')
    this.showNextTask({ spinner: '.merge' })
    return e?.stopPropagation()
  },

  action (actionName) {
    return this.currentTaskModel[actionName]()
    .catch(this.handleActionError.bind(this, this.currentTaskModel))
  },

  handleActionError (actionTaskModel, err) {
    error_.complete(err, '.alertWrapper', false)
    forms_.catchAlert(this, err)
    return this.showFromModel(actionTaskModel)
  },

  showNextTaskFromButton (e) {
    this.showNextTask({ spinner: '.next' })
    return e?.stopPropagation()
  },

  triggerActionByKey (e) {
    // Prevent interpretting browser shortkeys such as Alt+D or Ctrl+R
    // as action keys
    if (e.altKey || e.ctrlKey || e.metaKey) { return }

    switch (e.key) {
    case 'd': return this.dismiss()
    case 'm': return this.merge()
    case 'w': return this.mergeAndDeduplicate()
    case 'n': return this.showNextTaskFromButton()
    case 'r': return this.toggleRelatives()
    default:
      if (/^\d+$/.test(e.key)) {
        return this.showRelativeFromIndex(parseInt(e.key) - 1)
      }
    }
  },

  toggleRelatives () {
    this.$el.toggleClass('wrapped-controls')
    return this.ui.relativesToggler.toggleClass('toggled')
  },

  showRelativeFromIndex (index) {
    const el = this.relativeTasks.$el.find('.relative-task')[index]
    const taskId = el?.attributes['data-task-id'].value
    if (taskId != null) { return this.showFromId(taskId) }
  },

  updateRelativesCount (task) {
    let risk, text
    const { mergeSuggestions: suggestions } = task.suspect
    const currentSuggestionScore = task.get('globalScore')
    const highestSuggestionsScore = suggestions.getHighestScore(task.id)
    // Remove the current task from the count
    const count = suggestions.length - 1
    if (count === 0) {
      text = _.i18n('has no homonym')
      risk = 'none'
      this.ui.relativesToggler.css('visibility', 'hidden')
    } else {
      text = _.i18n('homonyms_count', { smart_count: count })
      this.ui.relativesToggler.css('visibility', null)
      if ((currentSuggestionScore - highestSuggestionsScore) < 10) {
        risk = 'high'
      } else {
        risk = 'medium'
      }
    }

    this.ui.homonymsCount.text(text)
    return this.ui.homonymsCount.attr('data-risk', risk)
  }
})

const getTaskById = id => _.preq.get(app.API.tasks.byIds(id))
.get('tasks')
.then(tasks => {
  const task = tasks[0]
  if (task != null) {
    return new Task(task)
  } else { throw error_.new('not found', 404, { id }) }
})

const openDeduplicationLayoutIfDone = function (previousTask, currentTaskModel) {
  if (previousTask == null) { return }

  const previousSuggestionUri = previousTask.get('suggestionUri')
  const currentSuggestionUri = currentTaskModel.get('suggestionUri')
  if (previousSuggestionUri === currentSuggestionUri) { return }

  const { suggestion } = previousTask
  const showDeduplication = () => app.execute('show:deduplicate:sub:entities', suggestion, { openInNewTab: true })

  if (waitingForMerge != null) {
    return waitingForMerge
    .delay(100)
    .then(showDeduplication)
  } else {
    return setTimeout(showDeduplication, 100)
  }
}
