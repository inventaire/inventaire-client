module.exports = Backbone.Collection.extend
  byUri: (uri)-> @findWhere {uri: uri}