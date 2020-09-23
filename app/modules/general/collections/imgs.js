export default Backbone.Collection.extend({
  model: require('../models/img'),
  invalidImage (model, err) {
    this.remove(model)
    return this.trigger('invalid:image', err)
  }
})
