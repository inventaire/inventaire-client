properties = require 'modules/entities/lib/properties'
typeSearch = require './type_search'

sources =
  humans: typeSearch 'humans'
  genres: typeSearch 'genres'
  series: typeSearch 'series'
  topics: typeSearch 'topics'
  languages: typeSearch 'languages'
  publishers: typeSearch 'publishers'

module.exports = (property)->
  { source } = properties[property]
  return sources[source]
