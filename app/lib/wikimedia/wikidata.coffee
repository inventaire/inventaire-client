preq = requireProxy 'lib/preq'
wdLang = require 'wikidata-lang'
wd_ = sharedLib('wikidata')(preq, _)

module.exports = _.extend wd_,
  getOriginalLang: (claims)->
    langClaims = _.pick claims, langProperties
    if _.objLength(langClaims) is 0 then return

    originalLangUri = _.pickOne(langClaims)?[0]
    if originalLangUri?
      wdId = wd_.unprefixifyEntityId originalLangUri
      return wdLang.byWdId[wdId]?.code

  # It sometimes happen that a Wikidata label is a direct copy of the Wikipedia
  # title, which can then have desambiguating parenthesis: we got to drop those
  formatLabel: (label)-> label.replace /\s\(.*\)$/, ''

langProperties = [
  'wdt:P103' # native language
  'wdt:P364' # original language of work
]
