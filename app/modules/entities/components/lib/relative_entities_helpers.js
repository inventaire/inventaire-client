import { i18n } from '#user/lib/i18n'
import { inverseLabels } from '#entities/components/lib/claims_helpers'

export function getReverseClaimLabel ({ property, entity }) {
  const label = inverseLabels[property]
  if (label) return i18n(label, { name: entity.label })
}

export function getRelativeEntitiesProperties (type, mainProperty) {
  // TODO: add genre relatives
  let properties = reverseClaimPropertiesByType[type]
  // Omit the property already displayed in the entity browser of a claim layout.
  if (mainProperty) properties = _.without(properties, mainProperty)
  return properties || []
}

export function getRelativeEntitiesClaimProperties (type) {
  return claimPropertiesByType[type] || []
}

const reverseClaimPropertiesByType = {
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
    'wdt:P655', // translator
    'wdt:P737', // influenced by
    'wdt:P921', // main subject
  ],
}

export const claimPropertiesByType = {
  human: [
    'wdt:P737', // influencing
    'wdt:P166', // award received
  ],
}
