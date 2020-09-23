export default Backbone.Collection.extend({
  model: require('../models/shelf'),

  initialize(models, options = {}){
    return this.selected = options.selected || [];
  },

  comparator(shelf){
    if (this.selected.includes(shelf.id)) { return '0' + shelf.get('name').toLowerCase();
    } else { return '1' + shelf.get('name').toLowerCase(); }
  }
});
