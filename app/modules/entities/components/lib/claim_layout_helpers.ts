import { infoboxPropertiesByType } from '#entities/components/lib/claims_helpers'
import { pluralize } from '#entities/lib/types/entities_types'

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
