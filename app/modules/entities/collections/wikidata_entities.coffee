Entities = require './entities'

module.exports = WikidataEntities = Entities.extend
  model: require '../models/wikidata_entity'
  byType: (type)-> _(@models).where {type: type}