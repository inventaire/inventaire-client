searchType = require './search_type'

module.exports = (type)->
  wdSearch = searchType.wikidata type
  invSearch = searchType.inventaire type
  return (search)->
    Promise.all [
      wdSearch search
      invSearch search
    ]
    .then _.flatten
