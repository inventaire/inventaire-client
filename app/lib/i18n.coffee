module.exports =
  # Convention: 'lang' always stands for ISO 639-1 two letters language codes (like 'en', 'fr', etc.)
  initialize: (app)->
    app.reqres.setHandlers

      'i18n:set': (lang)->
        app.vent.trigger('i18n:set', lang)
        setLanguage(app, lang)

      'qLabel:update': (lang = app.user.lang)->
        app.vent.trigger('qLabel:update', lang)
        switchLang = -> $.qLabel.switchLanguage(lang)
        # setTimeout-0 switchLang to put it at the end of the stack, to let the DOM update before qLabel looks for URIs
        setTimeout(switchLang, 0) if lang?

    app.vent.on 'i18n:set', (lang)-> app.request('qLabel:update', lang)
    app.vent.on 'qLabel:update', (lang)-> lang?.label('qLabel:update')

setLanguage = (app, lang)->
  polyglot = app.polyglot ||= new Polyglot
  if not lang?
    if app.user?.get 'language' then _.log(lang = app.user.get('language'), 'i18n: user data')
    else lang = guessLanguage()
  else _.log lang, 'i18n: from request parameters'

  if _.isEmpty(polyglot.phrases) || (lang isnt polyglot.currentLocale)
    if lang isnt polyglot.changingTo then requestI18nFile polyglot, lang
    else _.log 'language changing, can not be re-set yet'
  else _.log 'i18n is already set'

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
  if lang = $.cookie 'lang' then lang.label('i18n: cookie')
  else if lang = (navigator.language || navigator.userLanguage) then lang.label('i18n: navigator')
  else 'en'.label('i18n: global default')