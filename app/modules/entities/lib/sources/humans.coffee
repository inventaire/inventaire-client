SearchResult = require '../models/search_result'
collection = new Backbone.Collection [], { model: SearchResult }
searches = []

module.exports = ->

  remote = (query)->
    _.log query, 'query'
    if query in searches
      _.log query, 'already queried'
      # keep a consistant interface by returning only promises
      return _.preq.resolved

    searches.push query

    searchHumans query
    .then collection.add.bind(collection)
    .catch _.Error('search humans')

  source =
    collection: collection
    remote: remote

searchBase = app.API.proxy 'https://data.inventaire.io/wikidata/humans/_search'
window.searchHumans = searchHumans = (query)->
  _.preq.postJSON searchBase, { query: { match_phrase_prefix: { _all: query } } }
  .then parseSearch
  .then _.Log('humans')

parseSearch = (res)->
  res.hits.hits
  .map _.property('_source')
