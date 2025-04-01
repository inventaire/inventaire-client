import Polyglot from 'node-polyglot'
import { writable } from 'svelte/store'
import { noop } from 'underscore'
import { API } from '#app/api/api'
import { config } from '#app/config'
import type { UserLang } from '#app/lib/active_languages'
import log_ from '#app/lib/loggers'
import preq from '#app/lib/preq'
import { capitalize } from '#app/lib/utils'
import { commands } from '#app/radio'
import i18nMissingKey from './i18n_missing_key.ts'
import translate from './translate.ts'

// General rule: one session -> one language. Which means that every language
// change triggers a page reload with the new language.
// This is less efficient than re-rendering everything once the new language
// strings were fetched, but it's so much simpler to handle, and less verbose as
// we don't need to clutter every layout with events listeners like
// @listenTo app.user, 'change:language', @render

let currentLangI18n = (key: string, context?: unknown) => {
  console.trace(`i18n function was called before we received language strings: ${key}`, context)
  return key
}

export const i18n = (key: string, context?: unknown) => currentLangI18n(key, context)

const missingKey = config.env === 'production' ? noop : i18nMissingKey

export let polyglot: Polyglot

function onMissingKey (key: string) {
  console.warn(`Missing translation for key: ${key}`)
  missingKey(key)
  if (key == null) console.trace()
  // @ts-expect-error `phrases` is missing in @types/node-polyglot
  polyglot.phrases[key] = key
  return polyglot.t(key)
}

let lastLocalLang
export const localLang = writable()

// Convention: 'lang' always stands for ISO 639-1 two letters language codes
// (like 'en', 'fr', etc.)
export async function initI18n (lang: UserLang) {
  setLanguage(lang).catch(log_.Error('setLanguage error'))
}

export const I18n = (key: string, context?: unknown) => capitalize(currentLangI18n(key, context))

async function setLanguage (lang: UserLang) {
  lastLocalLang = lang
  localLang.set(lang)
  polyglot = new Polyglot({ onMissingKey })
  currentLangI18n = translate(lang, polyglot)
  return requestI18nFile(lang)
}

const i18nStringsCache = {}
async function requestI18nFile (lang: UserLang) {
  i18nStringsCache[lang] ??= await preq.get(API.i18nStrings(lang))
  polyglot.replace(i18nStringsCache[lang])
  polyglot.locale(lang)
  commands.execute('waiter:resolve', 'i18n')
}

export async function updateI18nLang (lang: UserLang) {
  if (lang !== lastLocalLang) {
    await setLanguage(lang)
  }
}
