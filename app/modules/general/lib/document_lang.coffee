{ origin } = location

exports.keepBodyLangUpdated = ->
  updateBodyLang.call @, app.request('i18n:current')
  @listenTo app.vent, 'i18n:set', updateBodyLang.bind(@)

updateBodyLang = (lang)-> @$el.attr 'lang', lang


exports.keepHeadAlternateLangsUpdated = ->
  updateHeadAlternateLangs null, _.currentRoute()
  # we dont need to keep it udpated,
  # its just to help search engines find the appropriate url for static content
  # @listenTo app.vent, 'route:navigate', updateHeadAlternateLangs

updateHeadAlternateLangs = (section, route)->
  # the default lang - en - doesnt need a lang querystring to be set.
  # it could have one, but search engines need to know that the default url
  # they got matches this languages hreflang
  setHreflang route, false, 'en'
  # non-default langs needing a lang querystring
  [ 'fr', 'de' ].forEach setHreflang.bind(null, route, true)

setHreflang = (route, withLangQueryString, lang)->
  # can't use location.href directly as it seems
  # to be updatedafter route:navigate
  qs = _.currentQuerystring()
  href = "#{origin}/#{route}#{qs}"
  if withLangQueryString then href = _.setQuerystring href, 'lang', lang
  $("head link[hreflang='#{lang}']").attr 'href', href
