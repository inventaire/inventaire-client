Tasks = Backbone.Collection.extend
  model: require '../models/task'

TasksView = Marionette.CollectionView.extend
  childView: require './task'

module.exports = Marionette.LayoutView.extend
  id: 'tasksLayout'
  template: require './templates/tasks_layout'

  regions:
    tasks: '#tasks'

  initialize: ->
    @collection = new Tasks
    @getTasks()

  getTasks: ->
    _.preq.get app.API.tasks.byScore
    .get 'tasks'
    .then @collection.add.bind(@collection)

  onShow: ->
    @tasks.show new TasksView({ collection: @collection })
