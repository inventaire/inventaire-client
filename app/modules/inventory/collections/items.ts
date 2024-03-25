import Item from '../models/item.ts'

export default Backbone.Collection.extend({
  model: Item,
  comparator (item) { return -item.get('created') },
})
