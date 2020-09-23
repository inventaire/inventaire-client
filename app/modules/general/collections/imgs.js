module.exports = Backbone.Collection.extend
  model: require '../models/img'
  invalidImage: (model, err)->
    @remove model
    @trigger 'invalid:image', err
