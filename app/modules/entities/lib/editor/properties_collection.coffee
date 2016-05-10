PropertyValue = require 'modules/entities/models/property_value'

work =
  # P31: true
  P50: true
  # P110: true
  # P577: false
  # P179: false
  # P1476: false
  # P1680: false
  # P364: false
  # P155: false
  # P156: false
  # P136: true
  # P921: true
  # P840: true
  # P674: true

module.exports = (entityModel)->
  propertiesCollection = new Backbone.Collection
  for prop, multivalue of work
    propertyModel = getPropertyModel entityModel, prop, multivalue
    propertiesCollection.add propertyModel

  return propertiesCollection

getPropertyModel = (entityModel, prop, multivalue)->
  propertyModel = new Backbone.Model
    property: prop
    multivalue: multivalue
  propertyModel.values = getPropertyValuesCollection entityModel, prop
  return propertyModel

getPropertyValuesCollection = (entityModel, prop)->
  claims = entityModel.get("claims.#{prop}") or []
  propValuesCollection = new Backbone.Collection
  for val in claims
    model = new PropertyValue
      property: prop
      value: val
    model.entity = entityModel
    propValuesCollection.add model

  return propValuesCollection
