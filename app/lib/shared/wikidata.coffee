{ Q } = require './wikidata_aliases'
wdLang = require 'wikidata-lang'

module.exports = (promises_, _)->
  API = require('./wikidata_api')(_)

  unprefixifyEntityId = (value)-> value.replace 'wd:', ''

  return helpers =
    API: API
    isAuthor: (P106Array=[])-> _.haveAMatch Q.authors, P106Array
    unprefixifyEntityId: unprefixifyEntityId

    getOriginalLang: (claims)->
      langClaims = _.pick claims, langProperties
      if _.objLength(langClaims) is 0 then return

      originalLangUri = _.pickOne(langClaims)?[0]
      if originalLangUri?
        wdId = unprefixifyEntityId originalLangUri
        return wdLang.byWdId[wdId]?.code

langProperties = [
  'wdt:P103' # native language
  'wdt:P364' # original language of work
  'wdt:P407' # language of work
]
