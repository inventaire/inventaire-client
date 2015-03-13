module.exports = (app)->
  app.user.on 'change:language', (data)->
    lang = app.user.get('language')
    if lang isnt app.polyglot.currentLocale
      _.log lang, 'i18n: user data change: i18n change requested'
      app.request 'i18n:set', lang
      _.setCookie 'lang', lang