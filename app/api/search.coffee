{ base } = require('./endpoint')('search')

module.exports = (types, search, lang)->
  types = _.forceArray(types).join '|'
  search = encodeURIComponent search
  return _.buildPath base, { types, search, lang }
