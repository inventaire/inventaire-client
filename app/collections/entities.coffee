module.exports = class Entities extends Backbone.Collection
  localStorage: new Backbone.LocalStorage("Entities")
  byUri: (uri)-> @findWhere {uri: uri}