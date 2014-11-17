module.exports = class Entities extends Backbone.Collection
  byUri: (uri)-> @findWhere {uri: uri}