import propertiesPerType from '#entities/lib/editor/properties_per_type'
import { typeHasName } from '#entities/lib/types/entities_types'
import { i18n } from '#user/lib/i18n'

export function getMissingRequiredProperties ({ entity, requiredProperties, requiresLabel, type }) {
  const missingRequiredProperties = []
  if (requiresLabel) {
    if (Object.keys(entity.labels).length <= 0) {
      if (typeHasName(type)) {
        missingRequiredProperties.push(i18n('name'))
      } else {
        missingRequiredProperties.push(i18n('title'))
      }
    }
  }
  for (const property of requiredProperties) {
    if (entity.claims[property]?.length <= 0) {
      const labelKey = propertiesPerType[type][property].customLabel || property
      missingRequiredProperties.push(i18n(labelKey))
    }
  }
  return missingRequiredProperties
}
