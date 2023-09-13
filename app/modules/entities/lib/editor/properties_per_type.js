import { pluralize } from '#entities/lib/types/entities_types'
import { infoboxPropertiesByType } from '#entities/components/lib/claims_helpers'
import { deepClone, flatMapKeyValues } from '#lib/utils'
import { getWorkPreferredAuthorRolesProperties } from '#entities/lib/editor/properties_per_subtype'
import { isNonEmptyArray } from '#lib/boolean_tests'
import preq from '#lib/preq'
import { API } from '#app/api/api'
import { propertiesEditorsConfigs } from '#entities/lib/properties'
import log_ from '#lib/loggers'

export const properties = await preq.get(API.data.properties).then(({ properties }) => properties)

export const propertiesPerType = {}
export const propertiesPerCategory = {}

for (const [ property, propertyMetadata ] of Object.entries(properties)) {
  if (propertiesEditorsConfigs[property]) {
    const { subjectTypes, category = 'general' } = propertyMetadata
    for (const type of subjectTypes) {
      propertiesPerType[type] = propertiesPerType[type] || {}
      propertiesPerType[type][property] = propertyMetadata
      propertiesPerCategory[category] = propertiesPerCategory[category] || []
      propertiesPerCategory[category].push(property)
    }
  } else {
    log_.warn(`property not implemented: ${property}`)
  }
}

export const locallyCreatableEntitiesTypes = Object.keys(propertiesPerType)

export const requiredPropertiesPerType = {
  edition: [ 'wdt:P629', 'wdt:P1476', 'wdt:P407' ],
  collection: [ 'wdt:P1476', 'wdt:P123' ]
}

export const propertiesCategories = {
  socialNetworks: { label: 'social networks' },
  bibliographicDatabases: { label: 'bibliographic databases' },
}

const categoryPerProperty = {}

for (const [ key, categoryData ] of Object.entries(propertiesPerCategory)) {
  for (const property of categoryData) {
    categoryPerProperty[property] = key
  }
}

const propertiesPerTypeAndCategory = {}

for (const [ type, propertiesData ] of Object.entries(propertiesPerType)) {
  propertiesPerTypeAndCategory[type] = {}
  for (const [ property, propertyData ] of Object.entries(propertiesData)) {
    const category = categoryPerProperty[property]
    propertiesPerTypeAndCategory[type][category] = propertiesPerTypeAndCategory[type][category] || {}
    propertiesPerTypeAndCategory[type][category][property] = propertyData
  }
}

export const getSubentitiesTypes = property => {
  const subentitiesTypes = []
  Object.keys(infoboxPropertiesByType).forEach(type => {
    const typeProps = infoboxPropertiesByType[type]
    if (typeProps.includes(property) && type !== 'article') {
      subentitiesTypes.push(pluralize(type))
    }
  })
  return subentitiesTypes
}

export function getTypePropertiesPerCategory (entity) {
  const { type } = entity
  if (type === 'work' || type === 'serie') {
    const entityPropertiesPerTypeAndCategory = deepClone(propertiesPerTypeAndCategory[type])
    entityPropertiesPerTypeAndCategory.general = customizeAuthorProperties(entity, entityPropertiesPerTypeAndCategory.general)
    return entityPropertiesPerTypeAndCategory
  } else {
    return propertiesPerTypeAndCategory[type]
  }
}

function customizeAuthorProperties (entity, generalProperties) {
  return flatMapKeyValues(generalProperties, ([ property, propertySettings ]) => {
    if (property === 'wdt:P50') {
      const customAuthorProperties = getWorkPreferredAuthorRolesProperties(entity)
      let entries = customAuthorProperties.map(prop => [ prop, properties[prop] ])
      if (!customAuthorProperties.includes('wdt:P50') && isNonEmptyArray(entity.claims['wdt:P50'])) {
        entries = [
          [ 'wdt:P50', propertySettings ],
          ...entries
        ]
      }
      return entries
    } else if (propertySettings.contextual) {
      // Contextual author properties might have possibly been introduced by getWorkPreferredAuthorRolesProperties
      return []
    } else {
      return [ [ property, propertySettings ] ]
    }
  })
}
