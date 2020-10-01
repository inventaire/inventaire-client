import PropertyValues from 'modules/entities/collections/property_values'
import properties from '../properties'
import propertiesPerType from './properties_per_type'
import error_ from 'lib/error'

export default function (entityModel) {
  const propertiesCollection = new Backbone.Collection()

  const { type } = entityModel
  if (type == null) {
    throw error_.new('unknown entity type', entityModel)
  }

  const typeProps = propertiesPerType[type]
  if (typeProps == null) {
    throw error_.new(`no properties found for entity type: ${type}`, entityModel)
  }

  for (const prop in typeProps) {
    const typeCustomPropData = typeProps[prop]
    const propData = properties[prop]
    // Unless a custom label is set, pass the property id to the _.i18n function
    propData.propertyLabel = typeCustomPropData.customLabel || prop
    const propertyModel = getPropertyModel(entityModel, propData)
    propertiesCollection.add(propertyModel)
  }

  return propertiesCollection
};

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
