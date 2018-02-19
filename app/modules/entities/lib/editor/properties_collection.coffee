PropertyValues = require 'modules/entities/collections/property_values'
properties = require '../properties'
propertiesPerType = sharedLib('properties_per_type')(_)
error_ = require 'lib/error'

module.exports = (entityModel)->
  propertiesCollection = new Backbone.Collection

  { type } = entityModel
  unless type?
    throw error_.new 'unknown entity type', entityModel

  typeProps = propertiesPerType[type]
  unless typeProps?
    throw error_.new "no properties found for entity type: #{type}", entityModel

  for prop, typeCustomPropData of typeProps
    propData = properties[prop]
    # Unless a custom label is set, pass the property id to the _.i18n function
    propData.propertyLabel = typeCustomPropData.customLabel or prop
    propertyModel = getPropertyModel entityModel, propData

    # If the entity is being created in relation to another entity that entity
    # should be presented as fixed, as it would be quite a mess otherwise
    if entityModel.creating and entityModel.relation is prop
      propertyModel.set
        editorType: 'fixed-entity'
        multivalue: false

    propertiesCollection.add propertyModel

  return propertiesCollection

getPropertyModel = (entityModel, propData)->
  propertyModel = new Backbone.Model propData
  propertyModel.entity = entityModel
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
