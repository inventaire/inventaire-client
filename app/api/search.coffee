{ base } = require('./endpoint')('search')

module.exports = (types, search, lang)->
  types = _.forceArray(types).join '|'
  return _.buildPath base, { types, search, lang }
