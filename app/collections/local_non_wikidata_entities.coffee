NonWikidataEntities = require 'collections/non_wikidata_entities'

module.exports = class LocalNonWikidataEntities extends NonWikidataEntities
  localStorage: new Backbone.LocalStorage 'isbn:Entities'

  recoverDataById: (id)-> @localStorage.find({id:"isbn:#{id}"})