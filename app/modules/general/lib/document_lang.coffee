{ origin } = location
{ alternateLangs, territorialize } = require './active_langs'

exports.keepBodyLangUpdated = ->
  updateBodyLang.call @, app.request('i18n:current')
  @listenTo app.vent, 'i18n:set', updateBodyLang.bind(@)

updateBodyLang = (lang)-> @$el.attr 'lang', lang


exports.keepHeadAlternateLangsUpdated = ->
  updateHeadAlternateLangs null, _.currentRoute()
  # we dont need to keep it udpated,
  # its just to help search engines find the appropriate url for static content
  # @listenTo app.vent, 'route:change', updateHeadAlternateLangs

updateHeadAlternateLangs = (section, route)->
  # the default lang - en - doesnt need a lang querystring to be set.
  # it could have one, but search engines need to know that the default url
  # they got matches this languages hreflang
  setHreflang route, false, 'en'
  # non-default langs needing a lang querystring
  alternateLangs.forEach setHreflang.bind(null, route, true)

setHreflang = (route, withLangQueryString, lang)->
  # can't use location.href directly as it seems
  # to be updated after route:navigate

  # discarding querystring to only keep lang
  href = "#{origin}/#{route}"
  if withLangQueryString then href = _.setQuerystring href, 'lang', lang
  $("head link[hreflang='#{lang}']").attr 'href', href

exports.updateOgLocalAlternates = ->
  lang = app.request 'i18n:current'

  # set the current lang as 'og:locale'
  local = territorialize[lang]
  $('head').append "<meta property='og:locale' content='#{local}' />"

  # set the others as 'og:locale:alternate'
  otherTerritories = _.values _.omit(territorialize, lang)
  otherTerritories.forEach (territory)->
    $('head')
    .append "<meta property='og:locale:alternate' content='#{territory}' />"
