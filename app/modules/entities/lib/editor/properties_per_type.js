import { pluralize } from '#entities/lib/types/entities_types'
import preq from '#lib/preq'
import { API } from '#app/api/api'
import { allowedValuesPerTypePerProperty } from '#entities/components/editor/lib/suggestions/property_values_shortlist'
import { omit, pick } from 'underscore'

export const properties = await preq.get(API.data.properties).then(({ properties }) => properties)

export const propertiesPerType = {}
export const propertiesPerCategory = {}

for (const [ property, propertyMetadata ] of Object.entries(properties)) {
  const { subjectTypes, category = 'general' } = propertyMetadata
  const allowedValuesShortlist = allowedValuesPerTypePerProperty[property]
  for (const type of subjectTypes) {
    const propertyCanBeEdited = !allowedValuesShortlist || allowedValuesShortlist[pluralize(type)].length > 1
    if (propertyCanBeEdited) {
      propertiesPerType[type] = propertiesPerType[type] || {}
      propertiesPerType[type][property] = propertyMetadata
      propertiesPerCategory[category] = propertiesPerCategory[category] || []
      propertiesPerCategory[category].push(property)
    }
  }
}

export const priorityPropertiesPerType = {
  human: [ 'wdt:P1412' ],
  work: [ 'wdt:P31', 'wdt:P50' ],
  serie: [ 'wdt:P31', 'wdt:P50' ],
  edition: [ 'wdt:P629', 'wdt:P437', 'wdt:P1476', 'wdt:P1680', 'wdt:P123', 'invp:P2', 'wdt:P407', 'wdt:P577' ],
  publisher: [ 'wdt:P856', 'wdt:P112', 'wdt:P571', 'wdt:P576' ],
  collection: [ 'wdt:P1476', 'wdt:P123', 'wdt:P856' ],
  article: [],
}

const workAndSerieCustomLabels = {
  'wdt:P31': 'type',
  'wdt:P58': 'scenarist',
  'wdt:P98': 'editor',
  'wdt:P407': 'original language',
  'wdt:P577': 'first publication date',
}

const customLabels = {
  human: {},
  work: workAndSerieCustomLabels,
  serie: workAndSerieCustomLabels,
  edition: {
    'wdt:P1476': 'edition title',
    'wdt:P1680': 'edition subtitle',
    'wdt:P629': 'work from which this is an edition',
    'wdt:P407': 'edition language',
    'wdt:P2635': 'number of volumes',
  },
  publisher: {
    'wdt:P571': 'date of foundation',
    'wdt:P576': 'date of dissolution',
  },
  collection: {
    'wdt:P1476': 'collection title',
  },
  article: {}
}

for (const type of Object.keys(propertiesPerType)) {
  const typePriorityProperties = priorityPropertiesPerType[type]
  propertiesPerType[type] = {
    ...pick(propertiesPerType[type], typePriorityProperties),
    ...omit(propertiesPerType[type], typePriorityProperties),
  }
  const typeCustomLabels = customLabels[type]
  for (const [ property, customLabel ] of Object.entries(typeCustomLabels)) {
    propertiesPerType[type][property] = Object.assign({ customLabel }, propertiesPerType[type][property])
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

export const propertiesPerTypeAndCategory = {}

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
