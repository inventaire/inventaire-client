module.exports = class Entities extends Backbone.Collection
  initialize: -> @fetch()
  model: require 'models/non_wikidata_entity'
  localStorage: new Backbone.LocalStorage 'Entities'
  byUri: (uri)-> @findWhere {uri: uri}