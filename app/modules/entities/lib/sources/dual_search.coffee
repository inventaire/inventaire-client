WikidataSearch = require './wikidata_subset_search'
LocalSearch = require './local_search'

module.exports = (type)->
  wdSearch = WikidataSearch type
  localSearch = LocalSearch type
  return (search)->
    Promise.all [
      wdSearch search
      localSearch search
    ]
    .then _.flatten
