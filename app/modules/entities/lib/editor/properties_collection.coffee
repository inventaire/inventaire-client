PropertyValues = require 'modules/entities/collections/property_values'
properties = require '../properties'
{ book, edition } = require './properties_per_type'

module.exports = (entityModel)->
  propertiesCollection = new Backbone.Collection
  for prop in book
    propData = properties[prop]
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
