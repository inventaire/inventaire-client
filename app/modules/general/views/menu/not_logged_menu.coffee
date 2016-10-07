loginPlugin = require 'modules/general/plugins/login'
{ transifex } = require 'lib/urls'
{ languages } = require 'lib/active_languages'
mostCompleteFirst = (a, b)-> b.completion - a.completion
languagesList = _.values(languages).sort mostCompleteFirst

module.exports = Marionette.ItemView.extend
  template: require './templates/not_logged_menu'
  className: 'notLoggedMenu'
  initialize: ->
    loginPlugin.call @

  onShow: -> app.execute 'foundation:reload'

  serializeData: ->
    currentLanguage: languages[app.user.lang].native
    languages: languagesList
    transifex: transifex

  events:
    'click .option a': 'selectLang'

  selectLang: (e)->
    lang = e.currentTarget.attributes['data-lang'].value
    app.user.set 'language', lang
