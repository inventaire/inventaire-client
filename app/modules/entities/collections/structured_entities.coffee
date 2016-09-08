Entities = require './entities'

StructuredEntities = Entities.extend
  byType: (type)-> _(@models).where {type: type}

module.exports =
  WikidataEntities: StructuredEntities.extend
    model: require '../models/wikidata_entity'
  InvEntities: StructuredEntities.extend
    model: require '../models/inv_entity'
