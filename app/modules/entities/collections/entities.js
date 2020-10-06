import Entity from '../models/entity'

export default Backbone.Collection.extend({
  model: Entity,
  byUri (uri) { return this.findWhere({ uri }) }
})
