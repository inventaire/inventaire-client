LocalNonWikidataEntities = require './local_non_wikidata_entities'

module.exports = class TmpLocalNonWikidataEntities extends LocalNonWikidataEntities
  localStorage: new Backbone.LocalStorage 'tmp:isbn:Entities'