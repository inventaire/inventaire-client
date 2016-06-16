{ origin } = location
{ langs, regionify } = require 'lib/active_languages'

# lang metadata updates needed by search engines
# or to make by-language css rules (with :lang)
module.exports = ($app, lang)->
  setAppLang $app, lang

  $head = $('head')
  setHeadAlternateLangs $head, _.currentRoute()
  setOgLocalAlternates $head, lang

setAppLang = ($app, lang)-> $app.attr 'lang', lang

setHeadAlternateLangs = ($head, currentRoute)->
  href = "#{origin}/#{currentRoute}"
  # Non-default langs needing a lang querystring
  for lang in langs
    if lang isnt 'en' then setHreflang $head, href, true, lang
  # The default lang - en - doesnt need a lang querystring to be set.
  # It could have one, but search engines need to know that the default url
  # they got matches this languages hreflang
  setHreflang $head, href, false, 'en'

setHreflang = ($head, href, withLangQueryString, lang)->
  # Can't use location.href directly as it seems
  # to be updated after route:navigate
  # Discarding querystring to only keep lang
  if withLangQueryString then href = _.setQuerystring href, 'lang', lang
  $head.find("link[hreflang='#{lang}']").attr 'href', href

setOgLocalAlternates = ($head, lang)->
  # set the current lang as 'og:locale'
  local = regionify[lang]
  $head.append "<meta property='og:locale' content='#{local}' />"

  # set the others as 'og:locale:alternate'
  otherTerritories = _.values _.omit(regionify, lang)
  for territory in otherTerritories
    $head.append "<meta property='og:locale:alternate' content='#{territory}' />"
