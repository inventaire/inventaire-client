browserLocale = require 'browser-locale'

module.exports = (userLanguage)->
  # querystring parameters > other settings sources
  qsLang = app.request 'querystring:get', 'lang'
  lang = qsLang or userLanguage or guessLanguage()
  return _.log _.shortLang(lang), 'lang'

guessLanguage = ->
  lang = $.cookie 'lang'
  if lang? then return lang

  lang = browserLocale()
  if lang? then return lang

  return 'en'
