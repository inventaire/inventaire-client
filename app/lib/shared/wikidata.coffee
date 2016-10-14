{ Q } = require './wikidata_aliases'

module.exports = (promises_, _, wdk)->
  API = require('./wikidata_api')(_)

  unprefixifyEntityId = (value)-> value.replace 'wd:', ''

  return helpers =
    API: API
    getEntities: (ids, languages, props)->
      url = wdk.getEntities ids.map(unprefixifyEntityId), languages, props
      return promises_.get url

    isAuthor: (P106Array=[])-> _.haveAMatch Q.authors, P106Array
    unprefixifyEntityId: unprefixifyEntityId
