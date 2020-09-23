export default Backbone.Collection.extend({
  model: require('../models/entity'),
  byUri (uri) { return this.findWhere({ uri }) }
})
