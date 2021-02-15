// General rule: one session -> one language. Which means that every language
// change triggers a page reload with the new language.
// This is less efficient than re-rendering everything once the new language
// strings were fetched, but it's so much simpler to handle, and less verbose as
// we don't need to clutter every layout with events listeners like
// @listenTo app.user, 'change:language', @render
import Polyglot from 'node-polyglot'
import log_ from 'lib/loggers'
import preq from 'lib/preq'
import { capitalize } from 'lib/utils'
import translate from './translate'
import i18nMissingKey from './i18n_missing_key'

// Work around circular dependency
let update = _.noop
let refreshData = _.noop
const lateImport = async () => {
  ({ update, refreshData } = await import('lib/uri_label/uri_label'))
}
setTimeout(lateImport, 0)

let currentLangI18n = _.identity

export const i18n = (...args) => currentLangI18n(...args)

// Convention: 'lang' always stands for ISO 639-1 two letters language codes
// (like 'en', 'fr', etc.)
export const initI18n = async (app, lang) => {
  const missingKey = window.env === 'dev' ? i18nMissingKey : _.noop

  const onMissingKey = function (key) {
    console.warn(`Missing translation for key: ${key}`)
    missingKey(key)
    if (key == null) console.trace()
    return key
  }

  setLanguage(lang, onMissingKey)

  app.commands.setHandlers({
    'uriLabel:update': () => update(app.user.lang),
    'uriLabel:refresh': refreshData
  })

  initLocalLang(lang)
}

export const I18n = (...args) => capitalize(currentLangI18n(...args))

const setLanguage = function (lang, onMissingKey) {
  app.polyglot = new Polyglot({ onMissingKey })
  currentLangI18n = translate(lang, app.polyglot)
  app.vent.trigger('uriLabel:update')
  return requestI18nFile(app.polyglot, lang)
}

const requestI18nFile = (polyglot, lang) => {
  return preq.get(app.API.i18nStrings(lang))
  .then(updatePolyglot.bind(null, polyglot, lang))
  .catch(log_.ErrorRethrow(`i18n: failed to get the i18n file for ${lang}`))
}

const updatePolyglot = function (polyglot, lang, res) {
  polyglot.replace(res)
  polyglot.locale(lang)
  app.execute('waiter:resolve', 'i18n')
}

const initLocalLang = function (lang) {
  let lastLocalLang = lang
  app.vent.on('lang:local:change', value => { lastLocalLang = value })
  app.reqres.setHandlers({
    'lang:local:get': () => lastLocalLang
  })
}
