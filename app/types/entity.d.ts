import type { SerializedEntity, PropertyUri, InvClaimValue, EntityUri } from '#server/types/entity'

export type SerializedEntityWithLabel = SerializedEntity & {
  label: string
}

export type Facet = Record<InvClaimValue, EntityUri>
export type Facets = Record<PropertyUri, Facet>
export type FacetsSelectedValues = Record<PropertyUri, string>
