{ base } = require('./endpoint')('search')
{ buildPath } = require 'lib/location'

module.exports = (types, search, limit = 10)->
  { lang } = app.user
  types = _.forceArray(types).join '|'
  search = encodeURIComponent search
  return buildPath base, { types, search, lang, limit }
