module.exports =
  # Convention: 'lang' always stands for ISO 639-1 two letters language codes (like 'en', 'fr', etc.)
  initialize: (app)->
    app.reqres.setHandlers

      'i18n:set': (lang)->
        lang = solveLang(lang)
        setLanguage(app, lang)

      'qLabel:update': (lang)->
        lang or= app.user.lang
        lang = solveLang(lang)
        app.vent.trigger('qLabel:update', lang)
        switchLang = -> $.qLabel.switchLanguage(lang)
        # setTimeout-0 switchLang to put it at the end of the stack, to let the DOM update before qLabel looks for URIs
        setTimeout(switchLang, 0) if lang?

      'i18n:current': -> solveLang app.user.lang

    if window.env is 'dev'
      missingKey = require './i18n_missing_key'
    else missingKey = _.noop

    app.commands.setHandlers
      # called from a customized polyglot.js
      'i18n:missing:key': missingKey

    app.vent.on 'i18n:set', (lang)-> app.request('qLabel:update', lang)
    app.vent.on 'qLabel:update', (lang)-> lang?.logIt('qLabel:update')

setLanguage = (app, lang)->
  polyglot = app.polyglot or= new Polyglot
  if not lang?
    if app.user?.get 'language' then _.log(lang = app.user.get('language'), 'i18n: user data')
    else lang = guessLanguage()
  else _.log lang, 'i18n: from request parameters'

  app.vent.trigger('i18n:set', lang)

  if _.isEmpty(polyglot.phrases) or (lang isnt polyglot.currentLocale)
    if lang isnt polyglot.changingTo then requestI18nFile polyglot, lang
    else _.log 'i18n: language changing, can not be re-set yet'
  else _.log 'i18n: is already set'

requestI18nFile = (polyglot, lang)->
  polyglot.changingTo = lang
  return _.preq.get app.API.i18n(lang)
  .then (res)->
    polyglot.replace res
    polyglot.locale lang
    app.vent.trigger 'i18n:reset'
  .catch (err)->
    console.error "i18n: failed to get the i18n file for #{lang}"
    _.log err
  .then -> polyglot.changingTo = null
  .catch (err)-> _.logXhrErr err, 'requestI18nFile err'

guessLanguage = ->
  if lang = $.cookie 'lang' then lang.logIt('i18n: cookie')
  else if lang = (navigator.language?[0..1] or navigator.userLanguage[0..1]) then lang.logIt('i18n: navigator')
  else 'en'.logIt('i18n: global default')

# querystring parameters > other settings sources
solveLang = (lang)->
  qsLang = app.request 'route:querystring', 'lang'
  return qsLang or lang
