import Entity from '../models/entity.js'

export default Backbone.Collection.extend({
  model: Entity,
  byUri (uri) { return this.findWhere({ uri }) }
})
