import { i18n } from '#user/lib/i18n'
import { inverseLabels } from '#entities/components/lib/claims_helpers'

export function getRelativeEntitiesListLabel ({ property, entity }) {
  const label = inverseLabels[property] || ''
  return i18n(label, { name: entity.label })
}

export function getRelativeEntitiesProperties (type, mainProperty) {
  // TODO: add genre relatives
  let properties = relativeEntitiesPropertiesByType[type]
  // Omit the property already displayed in the entity browser of a claim layout.
  if (mainProperty) properties = _.without(properties, mainProperty)
  return properties || []
}

export const relativeEntitiesPropertiesByType = {
  work: [
    'wdt:P144', // based on
    'wdt:P941', // inspired by
    'wdt:P921', // main subject
  ],
  subject: [
    'wdt:P135', // movement
    'wdt:P144', // based on
    'wdt:P840', // narrative location
    'wdt:P921', // main subject
    'wdt:P941', // inspired by
    'wdt:P1433', // published in
    'wdt:P69', // educated at
  ],
  human: [
    'wdt:P135', // movement
    'wdt:P737', // influenced by
    'wdt:P921', // main subject
  ],
}
