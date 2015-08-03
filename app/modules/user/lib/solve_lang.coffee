guessLanguage = ->
  lang = $.cookie 'lang'
  if lang? then return lang

  lang = navigator.language or navigator.userLanguage
  if lang? then return lang

  return 'en'

guessShortLang = -> _.shortLang guessLanguage()

module.exports = (userLanguage)->
  # querystring parameters > other settings sources
  qsLang = app.request 'route:querystring:get', 'lang'
  lang = qsLang or userLanguage or guessLanguage()
  return _.log _.shortLang(lang), 'lang'
