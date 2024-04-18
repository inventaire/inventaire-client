import Polyglot, { type PolyglotOptions } from 'node-polyglot'
import { noop } from 'underscore'
import { API } from '#app/api/api'
import app from '#app/app'
// General rule: one session -> one language. Which means that every language
// change triggers a page reload with the new language.
// This is less efficient than re-rendering everything once the new language
// strings were fetched, but it's so much simpler to handle, and less verbose as
// we don't need to clutter every layout with events listeners like
// @listenTo app.user, 'change:language', @render
import type { UserLang } from '#app/lib/active_languages.ts'
import log_ from '#app/lib/loggers'
import preq from '#app/lib/preq'
import { capitalize } from '#app/lib/utils'
import i18nMissingKey from './i18n_missing_key.ts'
import translate from './translate.ts'

// Work around circular dependency
let update = noop
let refreshData = noop
async function lateImport () {
  ({ update, refreshData } = await import('#app/lib/uri_label/uri_label'))
}
setTimeout(lateImport, 0)

let currentLangI18n = (key: string, context?: unknown) => {
  console.trace(`i18n function was called before we received language strings: ${key}`, context)
  return key
}

export const i18n = (key: string, context?: unknown) => currentLangI18n(key, context)

// Convention: 'lang' always stands for ISO 639-1 two letters language codes
// (like 'en', 'fr', etc.)
export async function initI18n (lang: UserLang) {
  const missingKey = window.env === 'dev' ? i18nMissingKey : noop

  const onMissingKey = function (key: string) {
    console.warn(`Missing translation for key: ${key}`)
    missingKey(key)
    if (key == null) console.trace()
    app.polyglot.phrases[key] = key
    return app.polyglot.t(key)
  }

  setLanguage(lang, onMissingKey)

  app.commands.setHandlers({
    'uriLabel:update': update,
    'uriLabel:refresh': refreshData,
  })

  initLocalLang(lang)
}

export const I18n = (key: string, context?: unknown) => capitalize(currentLangI18n(key, context))

function setLanguage (lang: UserLang, onMissingKey: PolyglotOptions['onMissingKey']) {
  app.polyglot = new Polyglot({ onMissingKey })
  currentLangI18n = translate(lang, app.polyglot)
  app.vent.trigger('uriLabel:update')
  return requestI18nFile(app.polyglot, lang)
}

function requestI18nFile (polyglot: Polyglot, lang: UserLang) {
  return preq.get(API.i18nStrings(lang))
  .then(updatePolyglot.bind(null, polyglot, lang))
  .catch(log_.ErrorRethrow(`i18n: failed to get the i18n file for ${lang}`))
}

function updatePolyglot (polyglot: Polyglot, lang: UserLang, res) {
  polyglot.replace(res)
  polyglot.locale(lang)
  app.execute('waiter:resolve', 'i18n')
}

const initLocalLang = function (lang) {
  let lastLocalLang = lang
  app.vent.on('lang:local:change', value => { lastLocalLang = value })
  app.reqres.setHandlers({
    'lang:local:get': () => lastLocalLang,
  })
}
