SearchResult = require 'modules/entities/models/search_result'
elasticSearch = require './elastic_search'
wikidataSearch = require './wikidata_search'
languageSearch = require './language_search'

module.exports = (type)->
  collection = new Backbone.Collection [], { model: SearchResult }
  searches = []

  # the searchType function should take a query string
  # and return an array of results
  searchType = switch type
    when 'humans', 'genres', 'publishers' then elasticSearch type
    when 'topics' then wikidataSearch
    when 'languages' then languageSearch
    else throw new Error("unknown type: #{type}")

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
