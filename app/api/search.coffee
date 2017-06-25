{ base } = require('./endpoint')('search')

module.exports = (types, search)->
  _.buildPath base,
    types: _.forceArray(types).join '|'
    search: search
