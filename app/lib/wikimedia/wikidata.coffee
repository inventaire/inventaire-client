preq = requireProxy 'lib/preq'
wdk = require 'wikidata-sdk'
wdLang = require 'wikidata-lang'
wd_ = sharedLib('wikidata')(preq, _, wdk)

module.exports = _.extend wd_,
  getClaimSubjects: (property, value, refresh)->
    preq.get app.API.data.claim(property, value, refresh)
    .then _.Log("claim subjects - #{property}:#{value}")
    .get 'entities'

  queryAuthorWorks: (uri, refresh)->
    preq.get app.API.data.authorWorks(uri, refresh)
    .then _.Log("author work - #{uri}")
    .get 'entities'

  getOriginalLang: (claims, notSimplified)->
    langClaims = _.pick claims, langProperties
    if _.objLength(langClaims) is 0 then return

    # this has to be simplified claims
    if notSimplified then langClaims = wdk.simplifyClaims langClaims

    originalLangWdId = _.pickOne(langClaims)?[0]
    return wdLang.byWdId[originalLangWdId]?.code

  # It sometimes happen that a Wikidata label is a direct copy of the Wikipedia
  # title, which can then have desambiguating parenthesis: we got to drop those
  formatLabel: (label)-> label.replace /\s\(.*\)$/, ''

# P364: original language of work
# P103: native language
langProperties = [ 'wdt:P364', 'wdt:P103' ]
