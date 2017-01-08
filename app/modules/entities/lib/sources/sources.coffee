properties = require 'modules/entities/lib/properties'
typeSearch = require './type_search'

sources = {}

module.exports = (property)->
  { source } = properties[property]
  return sources[source] or (sources[source] = typeSearch source)
