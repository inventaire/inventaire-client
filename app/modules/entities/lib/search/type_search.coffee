SearchResult = require 'modules/entities/models/search_result'
wikidataSearch = require('./wikidata_search')(true)
searchType = require './search_type'
languageSearch = require './language_search'
{ getEntityUri, prepareSearchResult } = require './entities_uris_results'
error_ = require 'lib/error'

module.exports = (type, input, limit, offset)->
  entityUri = getEntityUri input

  if entityUri? then searchByEntityUri entityUri
  else getSearchTypeFn(type)(input, limit, offset)

searchByEntityUri = (uri)->
  _.log entityUri, 'entity uri'
  # As entering the entity URI triggers an entity request,
  # it might - in case of cache miss - make the server ask the search engine to
  # index that entity, so that it can be found by typing free text
  # instead of a URI next time
  # Refresh=true
  app.request 'get:entity:model', entityUri, true
  .catch _.Error('get entity err')
  .then (model)->
    # Ignore errors that were catched and thus didn't return anything
    unless model? then return

    pluarlizedType = if model.type? then model.type + 's'
    # The type subjects accepts any type, as any entity can be a topic
    # Known issue: languages entities aren't attributed a type by the server
    # thus thtowing an error here even if legit, prefer 2 letters language codes
    if pluarlizedType is type or type is 'subjects'
      return [ prepareSearchResult(model) ]
    else
      throw error_.new 'invalid entity type', 400, model

getSearchTypeFn = (type)->
  # the searchType function should take a input string
  # and return an array of results
  switch type
    when 'works', 'humans', 'series', 'genres', 'movements', 'publishers', 'collections' then searchType type
    when 'subjects' then wikidataSearch
    when 'languages' then languageSearch
    else throw new Error("unknown type: #{type}")
