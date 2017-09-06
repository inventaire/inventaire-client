SearchResult = require 'modules/entities/models/search_result'
wikidataSearch = require './wikidata_search'
searchType = require './search_type'
languageSearch = require './language_search'
{ getEntityUri, prepareSearchResult } = require './entities_uris_results'
error_ = require 'lib/error'

module.exports = (type)->
  collection = new Backbone.Collection [], { model: SearchResult }
  remote = getRemoteFn type, getSearchTypeFn(type), collection, []
  return API = { collection, remote }

getSearchTypeFn = (type)->
  # the searchType function should take a input string
  # and return an array of results
  switch type
    when 'works', 'humans', 'series', 'genres', 'movements', 'publishers' then searchType type
    when 'topics' then wikidataSearch
    when 'languages' then languageSearch
    else throw new Error("unknown type: #{type}")

lastInput = null
getRemoteFn = (type, searchType, collection, searches)-> (input)->
  _.log input, 'input'
  lastInput = input
  if input in searches
    _.log input, 'already queried'
    # keep a consistant interface by returning only promises
    return _.preq.resolved

  searches.push input

  entityUri = getEntityUri input
  if entityUri?
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

      # Ignore the results if the input changed
      if input isnt lastInput then return

      pluarlizedType = if model.type? then model.type + 's'
      # The type topics accepts any type, as any entity can be a topic
      if pluarlizedType is type or type is 'topics'
        # Reset the collection before so that previous text search or URI results
        # don't appear in the suggestions
        collection.reset()
        collection.add prepareSearchResult(model)
      else
        throw error_.new "invalid entity type", 400, model

  else
    searchType input
    .then collection.add.bind(collection)
    .catch _.Error("search #{type}")
