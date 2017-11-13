# General rule: one session -> one language. Which means that every language change triggers a page reload with the new language
# This is less efficient than re-rendering everything once the new language
# strings were fetched, but it's so much simpler to handle, and less verbose as
# we don't need to clutter every layout with events listeners like
# @listenTo app.user, 'change:language', @render

fetchMomentLocale = require './fetch_moment_local'
uriLabel = require 'lib/uri_label/uri_label'

# Convention: 'lang' always stands for ISO 639-1 two letters language codes
# (like 'en', 'fr', etc.)
module.exports = (app, lang)->
  if window.env is 'dev'
    missingKey = require './i18n_missing_key'
  else
    missingKey = _.noop

  missingKeyWarn = (warning)->
    console.warn warning

    # Warning pattern: "Missing translation for key: \"#{key}\""
    key = warning
      .replace 'Missing translation for key: "', ''
      .replace /"$/, ''

    missingKey key
    unless key? then console.trace()

  setLanguage lang, missingKeyWarn

  app.commands.setHandlers
    'uriLabel:update': updateUrilabel
    'uriLabel:refresh': uriLabel.refreshData

setLanguage = (lang, missingKeyWarn)->
  app.polyglot = new Polyglot { warn: missingKeyWarn }
  _.i18n = sharedLib('translate')(lang, app.polyglot)
  app.vent.trigger 'uriLabel:update'
  return requestI18nFile app.polyglot, lang

requestI18nFile = (polyglot, lang)->
  # If possible, let the whole lang as fetchMomentLocale as its own lang resolver
  fetchMomentLocale lang

  _.preq.get app.API.i18nStrings(lang)
  .then updatePolyglot.bind(null, polyglot, lang)
  .catch _.ErrorRethrow("i18n: failed to get the i18n file for #{lang}")

updatePolyglot = (polyglot, lang, res)->
  polyglot.replace res
  polyglot.locale lang
  app.execute 'waiter:resolve', 'i18n'

updateUrilabel = ->
  { lang } = app.user
  uriLabel.update lang
