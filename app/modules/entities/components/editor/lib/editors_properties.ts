import { isNonEmptyArray } from '#app/lib/boolean_tests'
import { deepClone, flatMapKeyValues } from '#app/lib/utils'
import { authorRolePropertiesSet, getWorkPreferredAuthorRolesProperties } from '#entities/lib/editor/properties_per_subtype'
import { properties, propertiesPerTypeAndCategory } from '#entities/lib/editor/properties_per_type'

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
          ...entries,
        ]
      }
      return entries
    } else if (authorRolePropertiesSet.has(property)) {
      // Author properties should be ignored as the relevant ones will have been added in customAuthorProperties
      return []
    } else {
      return [ [ property, propertySettings ] ]
    }
  })
}
