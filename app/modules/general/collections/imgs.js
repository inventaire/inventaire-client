import Img from '../models/img.js'

export default Backbone.Collection.extend({
  model: Img,
  invalidImage (model, err) {
    this.remove(model)
    this.trigger('invalid:image', err)
  }
})
