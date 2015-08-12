fetchMomentLocale = require './fetch_moment_local'

module.exports =
  # Convention: 'lang' always stands for ISO 639-1 two letters language codes (like 'en', 'fr', etc.)
  initialize: (app)->
    app.reqres.setHandlers
      # make sure to return a promise
      'i18n:set': -> _.preq.start().then setLanguage
      'qLabel:update': updateQlabel
      'i18n:current': -> app.user.lang

    if window.env is 'dev'
      missingKey = require './i18n_missing_key'
    else missingKey = _.noop

    app.commands.setHandlers
      # called from a customized polyglot.js
      'i18n:missing:key': missingKey

    app.vent.on 'i18n:set', updateQlabel

setLanguage = ->
  { lang } = app.user
  polyglot = app.polyglot or= new Polyglot
  app.vent.trigger 'i18n:set', lang

  changeNeeded = _.isEmpty(polyglot.phrases) or (lang isnt polyglot.currentLocale)
  unless changeNeeded
    # _.log 'i18n: is already set'
    return

  if lang isnt polyglot.changingTo then requestI18nFile polyglot, lang
  else _.warn 'i18n: language changing, can not be re-set yet'

requestI18nFile = (polyglot, lang)->
  polyglot.changingTo = lang
  # let the whole lang as fetchMomentLocale as its own lang resolver
  fetchMomentLocale lang

  _.preq.get app.API.i18n(lang)
  .then updatePolyglot.bind(null, polyglot, lang)
  .catch _.Error("i18n: failed to get the i18n file for #{lang}")
  .finally doneChanging.bind(null, polyglot)

updatePolyglot = (polyglot, lang, res)->
  polyglot.replace res
  polyglot.locale lang
  app.vent.trigger 'i18n:reset'

doneChanging = (polyglot)->
  polyglot.changingTo = null

updateQlabel = ->
  { lang } = app.user
  app.vent.trigger 'qLabel:update', lang

  # setTimeout-0 switchLang to put it at the end of the stack, to let the DOM update before qLabel looks for URIs
  switchLang = -> $.qLabel.switchLanguage(lang)
  setTimeout switchLang, 0
