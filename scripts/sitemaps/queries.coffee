{ getReverseClaims, sparqlQuery } = require 'wikidata-sdk'

queryFromProperty = (P, Q)->
  base = """
    ?book wdt:P31/wdt:P279* wd:Q571 .
    ?book wdt:#{P} ?item .
    """
  sparqlQuery "SELECT DISTINCT ?item WHERE { #{base} }"

module.exports =
  authors: queryFromProperty 'P50'
  books: getReverseClaims 'P31', 'Q571'
  genres: queryFromProperty 'P136'
  movements: queryFromProperty 'P135'
  subjects: queryFromProperty 'P921'
