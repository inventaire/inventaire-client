Entities = require './entities'

module.exports = class WikidataEntities extends Entities
  model: require '../models/wikidata_entity'
  byType: (type)-> _(@models).where {type: type}