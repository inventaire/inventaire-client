module.exports =
  # Convention: 'lang' always stands for the short language codes, like 'en', 'fr', etc.
  initialize: (app)->
    app.reqres.setHandler 'i18n:set', (lang)-> setLanguage(app, lang)

setLanguage = (app, lang)->
  polyglot = app.polyglot ||= new Polyglot
  if not lang?
    if app.user?.get 'language' then _.log(lang = app.user.get('language'), 'i18n: user data')
    else lang = guessLanguage()
  else _.log lang, 'i18n: from request parameters'

  if _.isEmpty(polyglot.phrases) || (lang isnt polyglot.currentLocale)
    if lang isnt polyglot.changingTo then requestI18nFile polyglot, lang
    else _.log 'language changing, can not be re-set yet'
  else _.log "i18n is already set"

requestI18nFile = (polyglot, lang)->
  polyglot.changingTo = lang
  return $.getJSON "/i18n/#{lang}.json"
  .then (res)->
    polyglot.replace _.log(res, 'i18n res')
    polyglot.locale lang
    app.vent.trigger 'i18n:reset'
  .fail (err)->
    console.error "failed to get the i18n file for #{lang}"
    _.log err
  .then -> polyglot.changingTo = null

guessLanguage = ->
  if lang = $.cookie 'lang' then _.log lang, 'i18n: cookie'
  else if lang = (navigator.language || navigator.userLanguage) then _.log lang, 'i18n: navigator'
  else _.log 'en', 'i18n: global default'