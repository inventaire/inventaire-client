import app from '#app/app'
import { newError } from '#app/lib/error'
import { arrayIncludes, forceArray } from '#app/lib/utils'
import { searchByTypes } from '#entities/lib/search/search_by_types'
import { pluralize } from '#entities/lib/types/entities_types'
import type { EntityType, PluralizedIndexedEntityType } from '#server/types/entity'
import { getEntityUri, prepareSearchResult } from './entities_uris_results.ts'
import { wikidataSearch } from './wikidata_search.ts'

export type PluralizedSearchableEntityType = PluralizedIndexedEntityType | 'subjects'
export type SearchableType = EntityType | PluralizedSearchableEntityType

export default async function (types: SearchableType[], input: string, limit?: number, offset?: number) {
  const uri = getEntityUri(input)
  types = forceArray(types).map(pluralize)

  if (uri != null) {
    const res = await searchByEntityUri(uri, types)
    // If no entity is found with what was found to look like a uri,
    // fallback on searching that input instead
    if (res) return res
  }

  if (arrayIncludes(types, 'subjects')) {
    return wikidataSearch({
      search: input,
      limit,
      offset,
      formatResults: true,
    })
  } else {
    return searchByTypes({
      types: types as PluralizedIndexedEntityType[],
      search: input,
      limit,
      offset,
    })
  }
}

async function searchByEntityUri (uri, types) {
  let model
  try {
    model = await app.request('get:entity:model', uri)
  } catch (err) {
    if (err.code === 'entity_not_found') return
    else throw err
  }

  if (model == null) return

  const pluarlizedModelType = (model.type != null) ? model.type + 's' : undefined
  // The type subjects accepts any type, as any entity can be a topic
  // Known issue: languages entities aren't attributed a type by the server
  // thus throwing an error here even if legit, prefer 2 letters language codes
  if (types.includes(pluarlizedModelType) || types.includes('subjects')) {
    return {
      results: [
        prepareSearchResult(model).toJSON(),
      ],
    }
  } else {
    throw newError('invalid entity type', 400, model)
  }
}
