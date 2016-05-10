properties = require 'modules/entities/lib/properties'

module.exports = (property)->
  { source } = properties[property]
  return require "./#{source}"
