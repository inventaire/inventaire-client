NonWikidataEntities = require 'collections/non_wikidata_entities'

module.exports = class LocalNonWikidataEntities extends NonWikidataEntities
  initialize: -> @fetch()
  localStorage: new Backbone.LocalStorage 'isbn:Entities'