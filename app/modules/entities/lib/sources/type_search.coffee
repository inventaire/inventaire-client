SearchResult = require 'modules/entities/models/search_result'
dataUrl = 'https://data.inventaire.io'

module.exports = (type)->
  collection = new Backbone.Collection [], { model: SearchResult }
  searches = []
  searchBase = "#{dataUrl}/wikidata/#{type}/_search"
  searchType = (query)->
    _.preq.post searchBase,
      query:
        match_phrase_prefix:
          _all: query

    .then parseSearch
    .then _.Log(type)

  remote = (query)->
    # _.log query, 'query'
    if query in searches
      _.log query, 'already queried'
      # keep a consistant interface by returning only promises
      return _.preq.resolved

    searches.push query

    searchType query
    .then collection.add.bind(collection)
    .catch _.Error("search #{type}")

  return API =
    collection: collection
    remote: remote

parseSearch = (res)->
  res.hits.hits
  .map _.property('_source')
