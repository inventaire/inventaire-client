import { uniq, clone } from 'underscore'
import wdLang from 'wikidata-lang'
import { langs as activeLangs } from '#app/lib/languages'
import log_ from '#app/lib/loggers'
import languagesData from '#assets/js/languages_data'
import { getCurrentLang } from '#modules/user/lib/i18n'
import type { Labels, WdEntityUri } from '#server/types/entity'
import { objectEntries, objectKeys } from './utils.ts'
import { unprefixify } from './wikimedia/wikidata.ts'

const { byCode: langByCode, byWdId: langByWdId } = wdLang

export const regionify: Record<string, string> = {}

interface LanguageInfo {
  lang: string
  native: string
  completion: number
}

export const languages: Record<string, LanguageInfo> = {}

for (const [ lang, languageData ] of objectEntries(languagesData)) {
  const { completion, defaultRegion } = languageData
  regionify[lang] = defaultRegion
  languages[lang] = {
    lang,
    native: getNativeLangName(lang),
    completion,
  }
}

export const langs = objectKeys<typeof languagesData>(languagesData)

export type UserLang = typeof langs[number]

// Generated with https://w.wiki/5cVs
const rtlLang = new Set([ 'ace', 'ady', 'aeb', 'ar', 'arc', 'arq', 'ary', 'arz', 'az', 'bej', 'bjn', 'bm', 'bqi', 'bsk', 'ckb', 'dar', 'diq', 'dv', 'ett', 'fa', 'ff', 'glk', 'ha', 'hbo', 'he', 'jv', 'kbd', 'khw', 'kk', 'kr', 'ks', 'ku', 'kum', 'ky', 'lad', 'lki', 'lrc', 'luz', 'min', 'ms', 'mzn', 'non', 'nqo', 'ota', 'otk', 'pa', 'pnb', 'ps', 'qya', 'rif', 'sd', 'sdh', 'shi', 'shy', 'sw', 'syc', 'ta', 'tg', 'tk', 'tru', 'tzm', 'ug', 'uz', 'uzs', 'wbl', 'wo', 'xpu' ])

export function getTextDirection (lang = 'en') {
  const languageFamilyCode = lang.split('-')[0]
  return rtlLang.has(languageFamilyCode) ? 'rtl' : 'ltr'
}

export function getNativeLangName (code: string) {
  return langByCode[code]?.native
}

export function getWikimediaLanguageCodeFromWdUri (uri: WdEntityUri) {
  const wdId = unprefixify(uri)
  return langByWdId[wdId]?.code
}

export function getWdUriFromWikimediaLanguageCode (lang: string) {
  const langWdId = langByCode[lang]?.wd
  if (langWdId) return `wd:${langWdId}` as WdEntityUri
}

function availableLangList (availableLangs: string[], selectedLang: string) {
  return availableLangs
  .map(lang => {
    let langObj = langByCode[lang]
    if (langObj == null) {
      log_.warn(`lang not found in wikidata-lang: ${lang}`)
      langObj = { code: lang, label: lang, native: lang }
    }

    langObj = clone(langObj)
    if (langObj.code === selectedLang) langObj.selected = true
    return langObj
  })
  .sort(alphabetically)
}

const alphabetically = (a, b) => a.code > b.code ? 1 : -1

export function getLangsData (selectedLang: string, labels: Labels) {
  const availableLangs = Object.keys(labels)
  const highPriorityLangs = [ getCurrentLang(), 'en' ]
  const allLangs = uniq(availableLangs.concat(highPriorityLangs, activeLangs))
  // No distinction is made between available langs and others
  // as we can't style the <option> element anyway
  return availableLangList(allLangs, selectedLang)
}
