import { arrayIncludes, objectEntries } from '#app/lib/utils'
import { getUriNumericId } from '#app/lib/wikimedia/wikidata'
import { authorRoleProperties } from '#entities/lib/editor/properties_per_subtype'
import { properties, type CustomPropertyConfig } from '#entities/lib/editor/properties_per_type'
import type { ExtendedEntityType, InvPropertyClaims, PropertyUri } from '#server/types/entity'

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
] as const

export type AuthorProperty = typeof authorProperties[number]

const propertiesWithAllowEntityCreation = [
  ...authorProperties,
  'wdt:P123',
  'wdt:P179',
  'wdt:P195',
  'wdt:P629',
  'wdt:P655',
  'wdt:P737',
  'wdt:P2679',
  'wdt:P2680',
] as const

interface EditorCustomization {
  datatype?: string
  order?: number
  canValueBeDeleted?: ({ propertyClaims }: { propertyClaims: InvPropertyClaims }) => boolean
  entityValueTypes?: ExtendedEntityType[]
  specialEditActions?: 'author-role'
  allowEntityCreation?: boolean
}

const propertiesEditorsCustomizations: Record<PropertyUri, EditorCustomization> = {
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
    entityValueTypes: [ 'subject' ],
  },
  // ISBN-10
  'wdt:P957': {
    datatype: 'fixed-string',
  },
}

// Sorted by display order
const prioritizedProperties = [
  'wdt:P31', // instance of
  'wdt:P1476', // title
  'wdt:P1680', // subtitle
  'wdt:P629', // edition of
  'wdt:P212', // ISBN-13
  'wdt:P957', // ISBN-10
  'wdt:P179', // part of serie
  'wdt:P1545', // serie ordinal
  ...authorRoleProperties,
  'wdt:P7937', // form of creative work
  'wdt:P136', // genre
]

for (const property of prioritizedProperties) {
  propertiesEditorsCustomizations[property] ??= {}
  Object.assign(propertiesEditorsCustomizations[property], {
    // The lowest the `order` value, the higher the property will be displayed
    order: prioritizedProperties.indexOf(property) - prioritizedProperties.length,
  })
}

type PropertiesEditorConfig = { property: PropertyUri } & CustomPropertyConfig & EditorCustomization
export const propertiesEditorsConfigs: Record<PropertyUri, PropertiesEditorConfig> = {}

for (const [ property, propertyConfig ] of objectEntries(properties)) {
  const editorCustomization: EditorCustomization = propertiesEditorsCustomizations[property] || {}
  if (arrayIncludes(authorProperties, property)) {
    editorCustomization.specialEditActions = 'author-role'
  }
  if (arrayIncludes(propertiesWithAllowEntityCreation, property)) {
    editorCustomization.allowEntityCreation = true
  }
  editorCustomization.order = editorCustomization.order || (1000 + getUriNumericId(property))
  propertiesEditorsConfigs[property] = Object.assign({ property }, propertyConfig, editorCustomization)
}

export function reorderProperties (propertiesUris) {
  return propertiesUris.slice().sort((a, b) => propertiesEditorsConfigs[a].order - propertiesEditorsConfigs[b].order)
}
