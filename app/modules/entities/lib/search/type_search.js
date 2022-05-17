import searchType from './search_type.js'
import languageSearch from './language_search.js'
import { getEntityUri, prepareSearchResult } from './entities_uris_results.js'
import error_ from '#lib/error'
import { pluralize } from '#entities/lib/types/entities_types'
import _wikidataSearch from './wikidata_search.js'

const wikidataSearch = _wikidataSearch(true)

export default async function (type, input, limit, offset) {
  const uri = getEntityUri(input)

  if (uri != null) {
    const res = await searchByEntityUri(uri, type)
    // If no entity is found with what was found to look like a uri,
    // fallback on searching that input instead
    if (res) return res
  }

  if (type) {
    type = pluralize(type)
    if (type === 'subjects') return wikidataSearch(input, limit, offset)
    if (type === 'languages') return languageSearch(input, limit, offset)
    return searchType(type)(input, limit, offset)
  } else {
    return searchType()(input, limit, offset)
  }
}

async function searchByEntityUri (uri, type) {
  let model
  try {
    model = await app.request('get:entity:model', uri)
  } catch (err) {
    if (err.code === 'entity_not_found') return
    else throw err
  }

  if (model == null) return

  const pluarlizedType = (model.type != null) ? model.type + 's' : undefined
  // The type subjects accepts any type, as any entity can be a topic
  // Known issue: languages entities aren't attributed a type by the server
  // thus thtowing an error here even if legit, prefer 2 letters language codes
  if ((pluarlizedType === type) || (type === 'subjects')) {
    return {
      results: [
        prepareSearchResult(model).toJSON()
      ]
    }
  } else {
    throw error_.new('invalid entity type', 400, model)
  }
}
