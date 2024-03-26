import app from '#app/app'
import { searchByTypes } from '#entities/lib/search/search_by_types'
import { pluralize } from '#entities/lib/types/entities_types'
import error_ from '#lib/error'
import { forceArray } from '#lib/utils'
import { getEntityUri, prepareSearchResult } from './entities_uris_results.ts'
import { wikidataSearch } from './wikidata_search.ts'

export default async function (types, input, limit, offset) {
  const uri = getEntityUri(input)
  types = forceArray(types).map(pluralize)

  if (uri != null) {
    const res = await searchByEntityUri(uri, types)
    // If no entity is found with what was found to look like a uri,
    // fallback on searching that input instead
    if (res) return res
  }

  if (types.includes('subjects')) {
    return wikidataSearch({
      search: input,
      limit,
      offset,
      formatResults: true,
    })
  } else {
    return searchByTypes({ types, search: input, limit, offset })
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
    throw error_.new('invalid entity type', 400, model)
  }
}
