import type { SerializedEntity, PropertyUri, InvClaimValue, EntityUri } from '#server/types/entity'

// From the client point of view, all entities are server-serialized
// The client can then perform further serialization
export type Entity = SerializedEntity

export type RedirectionsByUris = Record<EntityUri, EntityUri>

export type Facet = Record<InvClaimValue, EntityUri>
export type Facets = Record<PropertyUri, Facet>
export type FacetsSelectedValues = Record<PropertyUri, string>

export type QueryParams = Record<string, unknown>
