export default Backbone.Collection.extend({
  model: require('../models/task'),
  comparator (task) { return -task.get('globalScore') },
  getHighestScore (ignoreTaskId) {
    let highestTask = this.models[0]
    if (highestTask == null) { return 0 }
    if (highestTask.id === ignoreTaskId) { highestTask = this.models[1] }
    if (highestTask != null) { return highestTask.get('globalScore') } else { return 0 }
  }
})
