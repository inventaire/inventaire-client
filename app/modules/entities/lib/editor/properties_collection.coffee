PropertyValues = require 'modules/entities/collections/property_values'
properties = require '../properties'
propertiesPerType = require './properties_per_type'
error_ = require 'lib/error'

module.exports = (entityModel)->
  propertiesCollection = new Backbone.Collection

  { type } = entityModel
  unless type?
    throw error_.new 'unknown entity type', entityModel

  typeProps = propertiesPerType[type]
  unless typeProps?
    throw error_.new "no properties found for entity type: #{type}", entityModel

  for prop in typeProps
    propData = properties[prop]

    # Helping for development, should be removed once stable
    unless propData?
      throw error_.new 'missing property data: edit modules/entities/lib/properties.coffee', prop

    propertiesCollection.add getPropertyModel(entityModel, propData)

  return propertiesCollection

getPropertyModel = (entityModel, propData)->
  propertyModel = new Backbone.Model propData
  propertyModel.values = getPropertyValuesCollection entityModel, propData
  return propertyModel

getPropertyValuesCollection = (entityModel, propData)->
  { property, allowEntityCreation } = propData
  claims = entityModel.get("claims.#{property}") or []
  collection = new PropertyValues [],
    entity: entityModel
    property: property
    allowEntityCreation: allowEntityCreation

  collection.addClaimsValues claims

  return collection
