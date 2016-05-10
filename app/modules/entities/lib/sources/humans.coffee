SearchResult = require 'modules/entities/models/search_result'
collection = new Backbone.Collection [], { model: SearchResult }
searches = []

remote = (query)->
  # _.log query, 'query'
  if query in searches
    _.log query, 'already queried'
    # keep a consistant interface by returning only promises
    return _.preq.resolved

  searches.push query

  searchHumans query
  .then collection.add.bind(collection)
  .catch _.Error('search humans')

searchBase = app.API.proxy 'https://data.inventaire.io/wikidata/humans/_search'
searchHumans = (query)->
  _.preq.postJSON searchBase, { query: { match_phrase_prefix: { _all: query } } }
  .then parseSearch
  # .then _.Log('humans')

parseSearch = (res)->
  res.hits.hits
  .map _.property('_source')

module.exports =
  collection: collection
  remote: remote
