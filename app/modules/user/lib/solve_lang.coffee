browserLocale = require 'browser-locale'
{ langs:activeLangs } = require 'lib/active_languages'

module.exports = (userLanguage)->
  # querystring parameters > other settings sources
  qsLang = app.request 'querystring:get', 'lang'
  lang = qsLang or userLanguage or _.getCookie('lang') or browserLocale()
  lang = _.shortLang lang
  if lang? and lang in activeLangs then return lang
  else return 'en'
