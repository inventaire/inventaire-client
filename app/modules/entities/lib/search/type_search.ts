import { without } from 'underscore'
import { newError } from '#app/lib/error'
import { arrayIncludes, forceArray } from '#app/lib/utils'
import { searchByTypes } from '#entities/lib/search/search_by_types'
import { pluralize } from '#entities/lib/types/entities_types'
import type { SearchParams } from '#server/controllers/search/search'
import type { EntityUri, ExtendedEntityType, PluralizedIndexedEntityType, InvEntityUri, WdEntityUri } from '#server/types/entity'
import { getEntityByUri } from '../entities.ts'
import { wikidataSearch } from './wikidata_search.ts'

export type PluralizedSearchableEntityType = PluralizedIndexedEntityType | 'subjects'
// TODO: narrow down to exclude entity types that are not searchable: 'edition', 'article'
export type SearchableType = ExtendedEntityType | PluralizedSearchableEntityType

interface TypeSearchParams extends Pick<SearchParams, 'search' | 'limit' | 'offset' | 'claim'> {
  types: SearchableType[]
}

export async function typeSearch (params: TypeSearchParams) {
  const { search, limit, offset, claim } = params
  let { types } = params
  const uri = getEntityUri(search)
  types = forceArray(types).map(pluralize)

  if (uri != null) {
    const res = await searchByEntityUri(uri, types)
    // If no entity is found with what was found to look like a uri,
    // fallback on searching that input instead
    if (res) return res
  }

  if (arrayIncludes(types, 'subjects')) {
    return wikidataSearch({
      search,
      limit,
      offset,
      formatResults: true,
    })
  } else {
    // The 'edition' type might be passed to allow edition searchByEntityUri
    // but it will be rejected by search as editions are currently not indexed
    types = without(types, 'edition')
    return searchByTypes({
      types: types as PluralizedIndexedEntityType[],
      search,
      limit,
      offset,
      claim,
    })
  }
}

const wdIdPattern = /Q\d+/
const invIdPattern = /[0-9a-f]{32}/

export function getEntityUri (input: string) {
  // Match ids instead of URIs to be very tolerent on the possible inputs
  const wdId = input.match(wdIdPattern)?.[0]
  if (wdId != null) return `wd:${wdId}` as WdEntityUri
  const invId = input.match(invIdPattern)?.[0]
  if (invId != null) return `inv:${invId}` as InvEntityUri
}

async function searchByEntityUri (uri: EntityUri, types: SearchableType[]) {
  let entity
  try {
    entity = await getEntityByUri({ uri })
  } catch (err) {
    if (err.code === 'entity_not_found') return
    else throw err
  }

  if (entity == null) return

  const pluarlizedEntityType = (entity.type != null) ? entity.type + 's' : undefined
  // The type subjects accepts any type, as any entity can be a topic
  // Known issue: languages entities aren't attributed a type by the server
  // thus throwing an error here even if legit, prefer 2 letters language codes
  if (arrayIncludes(types, pluarlizedEntityType) || arrayIncludes(types, 'subjects')) {
    return {
      results: [
        entity,
      ],
    }
  } else {
    throw newError('invalid entity type', 400, { entity, types })
  }
}
