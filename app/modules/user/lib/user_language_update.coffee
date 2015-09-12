module.exports = (app)->
  app.user.on 'change:language', (data)->
    if app.polyglot?
      lang = app.user.get 'language'
      if lang isnt app.polyglot.currentLocale
        app.request 'i18n:set', lang
        _.setCookie 'lang', lang