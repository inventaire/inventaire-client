{ Q } = require './wikidata_aliases'

module.exports = (promises_, _)->
  API = require('./wikidata_api')(_)

  unprefixifyEntityId = (value)-> value.replace 'wd:', ''

  return helpers =
    API: API
    isAuthor: (P106Array=[])-> _.haveAMatch Q.authors, P106Array
    unprefixifyEntityId: unprefixifyEntityId
