module.exports =
  # Convention: 'lang' always stands for the short language codes, like 'en', 'fr', etc.
  initialize: (app)->
    app.reqres.setHandler 'i18n:set', (lang)-> setLanguage(app, lang)

setLanguage = (app, lang)->
  polyglot = app.polyglot ||= new Polyglot
  if not lang?
    if app.user?.get 'language'
      lang = app.user.get 'language'
      _.log lang, 'i18n: user data'
    else lang = guessLanguage()
  else _.log lang, 'i18n: from request parameters'

  if _.isEmpty(polyglot.phrases) || (lang isnt polyglot.currentLocale)
    if lang isnt polyglot.changingTo
      return requestI18nFile polyglot, lang
    else return _.log 'language changing, can not be re-set yet'
  else
    return _.log "i18n is already set"

requestI18nFile = (polyglot, lang)->
  polyglot.changingTo = lang
  return $.getJSON "/i18n/#{lang}.json"
  .then (res)->
    _.log res, 'i18n res'
    polyglot.replace res
    polyglot.locale lang
  .fail (err)->
    console.error "failed to get the i18n file for #{lang}"
    _.log err
  .then ->
    polyglot.changingTo = null

guessLanguage = ->
  if lang = $.cookie 'lang'
    _.log lang, 'i18n: cookie'
    return lang
  else if lang = (navigator.language || navigator.userLanguage)
    _.log lang, 'i18n: navigator'
    return lang
  else return 'en'