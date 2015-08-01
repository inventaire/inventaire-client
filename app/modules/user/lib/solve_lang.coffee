guessLanguage = ->
  lang = $.cookie 'lang'
  if lang? then return lang

  lang = navigator.language or navigator.userLanguage
  if lang? then return lang

  return 'en'

guessShortLang = -> _.shortLang guessLanguage()

# querystring parameters > other settings sources
module.exports = (lang)->
  qsLang = app.request 'route:querystring:get', 'lang'
  lang = qsLang or lang or guessLanguage()
  return _.shortLang lang