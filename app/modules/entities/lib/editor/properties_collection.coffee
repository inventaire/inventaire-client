PropertyValues = require 'modules/entities/collections/property_values'
{ book, edition } = require './properties_settings'

module.exports = (entityModel)->
  propertiesCollection = new Backbone.Collection
  for propData in book
    propertiesCollection.add getPropertyModel(entityModel, propData)

  return propertiesCollection

getPropertyModel = (entityModel, propData)->
  propertyModel = new Backbone.Model propData
  propertyModel.values = getPropertyValuesCollection entityModel, propData
  return propertyModel

getPropertyValuesCollection = (entityModel, propData)->
  { property } = propData
  claims = entityModel.get("claims.#{property}") or []
  collection = new PropertyValues [],
    entity: entityModel
    property: property

  collection.addClaimsValues claims

  return collection
