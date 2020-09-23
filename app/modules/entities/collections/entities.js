module.exports = Backbone.Collection.extend
  model: require '../models/entity'
  byUri: (uri)-> @findWhere { uri }
