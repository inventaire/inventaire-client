{ origin } = location
{ langs, regionify } = require 'lib/active_languages'
{ setQuerystring, currentRoute } = require 'lib/location'

# lang metadata updates needed by search engines
# or to make by-language css rules (with :lang)
module.exports = ($app, lang)->
  setAppLang $app, lang

  elements = []
  addAlternateLangs elements,
  addOgLocalAlternates elements, lang
  $('head').append elements.join('')

setAppLang = ($app, lang)-> $app.attr 'lang', lang

addAlternateLangs = (elements)->
  href = "#{origin}/#{currentRoute()}"
  # Non-default langs needing a lang querystring
  for lang in langs
    if lang isnt 'en' then addHreflang elements, href, true, lang
  # The default lang - en - doesnt need a lang querystring to be set.
  # It could have one, but search engines need to know that the default url
  # they got matches this languages hreflang
  addHreflang elements, href, false, 'en'

addHreflang = (elements, href, withLangQueryString, lang)->
  # Can't use location.href directly as it seems
  # to be updated after route:navigate
  # Discarding querystring to only keep lang
  if withLangQueryString then href = setQuerystring href, 'lang', lang
  elements.push "<link rel='alternate' href='#{href}' hreflang='#{lang}' />"

addOgLocalAlternates = (elements, lang)->
  # set the current lang as 'og:locale'
  local = regionify[lang]
  elements.push "<meta property='og:locale' content='#{local}' />"

  # set the others as 'og:locale:alternate'
  otherTerritories = _.values _.omit(regionify, lang)
  for territory in otherTerritories
    elements.push "<meta property='og:locale:alternate' content='#{territory}' />"
