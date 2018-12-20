{ base } = require('./endpoint')('search')
{ buildPath } = require 'lib/location'

module.exports = (types, search, lang)->
  types = _.forceArray(types).join '|'
  search = encodeURIComponent search
  return buildPath base, { types, search, lang }
