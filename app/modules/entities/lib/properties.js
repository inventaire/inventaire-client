import { properties } from '#entities/lib/editor/properties_per_type'

// TODO: get those properties from server/controllers/entities/lib/properties/properties.js#authorRelationsProperties
export const authorProperties = [
  'wdt:P50', // author
  'wdt:P58', // scenarist
  'wdt:P98', // editor
  'wdt:P110', // illustrator
  'wdt:P6338', // colorist
  'wdt:P9191', // letterer
  'wdt:P10836', // inker
  'wdt:P10837', // penciller
]

const propertiesWithAllowEntityCreation = authorProperties.concat([
  'wdt:P123',
  'wdt:P179',
  'wdt:P195',
  'wdt:P629',
  'wdt:P655',
  'wdt:P737',
  'wdt:P2679',
  'wdt:P2680',
])

const propertiesEditorsCustomizations = {
  // instance of
  'wdt:P31': {
    // Further checks, such as preventing type changes, will be performed server-side
    canValueBeDeleted: ({ propertyClaims }) => propertyClaims.length > 1,
  },
  // ISBN-13
  'wdt:P212': {
    datatype: 'fixed-string',
  },
  // main subject
  'wdt:P921': {
    searchType: 'subjects',
  },
  // ISBN-10
  'wdt:P957': {
    datatype: 'fixed-string',
  },
}

export const propertiesEditorsConfigs = {}

for (const [ property, propertyConfig ] of Object.entries(properties)) {
  const editorCustomization = propertiesEditorsCustomizations[property] || {}
  if (authorProperties.includes(property)) {
    editorCustomization.specialEditActions = 'author-role'
  }
  if (propertiesWithAllowEntityCreation.includes(property)) {
    editorCustomization.allowEntityCreation = true
  }
  propertiesEditorsConfigs[property] = Object.assign({ property }, editorCustomization, propertyConfig)
}
