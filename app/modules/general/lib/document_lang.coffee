module.exports =
  keepBodyLangUpdated: ->
    updateBodyLang.call @, app.request('i18n:current')
    @listenTo app.vent, 'i18n:set', updateBodyLang.bind(@)

updateBodyLang = (lang)-> @$el.attr 'lang', lang