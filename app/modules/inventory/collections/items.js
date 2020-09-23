export default Backbone.Collection.extend({
  model: require('../models/item'),
  comparator(item){ return -item.get('created'); }
});
