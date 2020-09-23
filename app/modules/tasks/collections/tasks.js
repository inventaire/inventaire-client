module.exports = Backbone.Collection.extend
  model: require '../models/task'
  comparator: (task)-> -task.get('globalScore')
  getHighestScore: (ignoreTaskId)->
    highestTask = @models[0]
    unless highestTask? then return 0
    if highestTask.id is ignoreTaskId then highestTask = @models[1]
    return if highestTask? then highestTask.get('globalScore') else 0
