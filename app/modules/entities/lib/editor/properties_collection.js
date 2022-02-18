import PropertyValues from '#modules/entities/collections/property_values'
import properties from '../properties.js'
import propertiesPerType from './properties_per_type.js'
import error_ from '#lib/error'
import { omit } from 'underscore'

export default function (entityModel) {
  const propertiesCollection = new Backbone.Collection()

  const { type, relation } = entityModel
  if (type == null) {
    throw error_.new('unknown entity type', entityModel)
  }

  let typeProps = propertiesPerType[type]
  if (typeProps == null) {
    throw error_.new(`no properties found for entity type: ${type}`, entityModel)
  }

  // When the entity being created has a relation to another entity being created,
  // do not offer to edit that relation property
  // (typically wdt:P629 when creating a work and an edition )
  if (relation) typeProps = omit(typeProps, relation)

  for (const prop in typeProps) {
    const typeCustomPropData = typeProps[prop]
    const propData = properties[prop]
    // Unless a custom label is set, pass the property id to the i18n function
    propData.propertyLabel = typeCustomPropData.customLabel || prop
    const propertyModel = getPropertyModel(entityModel, propData)
    propertiesCollection.add(propertyModel)
  }

  return propertiesCollection
}

const getPropertyModel = function (entityModel, propData) {
  const propertyModel = new Backbone.Model(propData)
  propertyModel.entity = entityModel
  propertyModel.values = getPropertyValuesCollection(entityModel, propData)
  return propertyModel
}

const getPropertyValuesCollection = function (entityModel, propData) {
  const { property, allowEntityCreation } = propData
  const claims = entityModel.get(`claims.${property}`) || []
  const collection = new PropertyValues([], {
    entity: entityModel,
    property,
    allowEntityCreation
  })

  collection.addClaimsValues(claims)

  return collection
}
