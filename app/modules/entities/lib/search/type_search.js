import searchType from './search_type'
import languageSearch from './language_search'
import EntitiesUrisResults from './entities_uris_results'

import error_ from 'lib/error'
import TypeKey from '../types/type_key'
const wikidataSearch = require('./wikidata_search')(true)

const {
  getEntityUri,
  prepareSearchResult
} = EntitiesUrisResults

const {
  pluralize
} = TypeKey

export default function (type, input, limit, offset) {
  const uri = getEntityUri(input)

  if (uri != null) {
    return searchByEntityUri(uri, type)
  } else {
    return getSearchTypeFn(type)(input, limit, offset)
  }
}

// As entering the entity URI triggers an entity request,
// it might - in case of cache miss - make the server ask the search engine to
// index that entity, so that it can be found by typing free text
// instead of a URI next time
// Refresh=true
const searchByEntityUri = (uri, type) => {
  return app.request('get:entity:model', uri, true)
  .catch(_.Error('get entity err'))
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

const getSearchTypeFn = function (type) {
  // if type.slice(-1)[0] isnt 's' then type += 's'
  type = pluralize(type)
  // the searchType function should take a input string
  // and return an array of results
  switch (type) {
  case 'works': case 'humans': case 'series': case 'genres': case 'movements': case 'publishers': case 'collections': return searchType(type)
  case 'subjects': return wikidataSearch
  case 'languages': return languageSearch
  default: throw new Error(`unknown type: ${type}`)
  }
}
