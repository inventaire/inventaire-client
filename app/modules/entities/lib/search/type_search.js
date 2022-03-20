import log_ from '#lib/loggers'
import searchType from './search_type.js'
import languageSearch from './language_search.js'
import { getEntityUri, prepareSearchResult } from './entities_uris_results.js'
import error_ from '#lib/error'
import TypeKey from '../types/type_key.js'
import _wikidataSearch from './wikidata_search.js'

const wikidataSearch = _wikidataSearch(true)

const { pluralize } = TypeKey

export default async function (type, input, limit, offset) {
  const uri = getEntityUri(input)

  if (uri != null) {
    return searchByEntityUri(uri, type)
  } else if (type) {
    type = pluralize(type)
    if (type === 'subjects') return wikidataSearch(input, limit, offset)
    if (type === 'languages') return languageSearch(input, limit, offset)
    return searchType(type)(input, limit, offset)
  } else {
    return searchType()(input, limit, offset)
  }
}

// As entering the entity URI triggers an entity request,
// it might - in case of cache miss - make the server ask the search engine to
// index that entity, so that it can be found by typing free text
// instead of a URI next time
// Refresh=true
const searchByEntityUri = (uri, type) => {
  return app.request('get:entity:model', uri, true)
  .catch(log_.Error('get entity err'))
  .then(model => {
    // Ignore errors that were catched and thus didn't return anything
    if (model == null) return

    const pluarlizedType = (model.type != null) ? model.type + 's' : undefined
    // The type subjects accepts any type, as any entity can be a topic
    // Known issue: languages entities aren't attributed a type by the server
    // thus thtowing an error here even if legit, prefer 2 letters language codes
    if ((pluarlizedType === type) || (type === 'subjects')) {
      return [ prepareSearchResult(model) ]
    } else {
      throw error_.new('invalid entity type', 400, model)
    }
  })
}
