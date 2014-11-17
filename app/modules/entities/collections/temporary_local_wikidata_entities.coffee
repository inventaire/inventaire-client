LocalWikidataEntities = require 'collections/local_wikidata_entities'

module.exports = class TmpLocalWikidataEntities extends LocalWikidataEntities
  localStorage: new Backbone.LocalStorage 'tmp:wd:Entities'