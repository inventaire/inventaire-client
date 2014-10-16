Entities = require 'collections/entities'

module.exports = class WikidataEntities extends Entities
  model: require '../models/wikidata_entity'
  byType: (type)-> @findWhere {type: type}