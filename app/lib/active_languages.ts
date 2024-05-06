import wdLang from 'wikidata-lang'
import languagesData from '#assets/js/languages_data'
import { objectEntries, objectKeys } from './utils.ts'

export const regionify = {}

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
    native: wdLang.byCode[lang].native,
    completion,
  }
}

export const langs = objectKeys<typeof languagesData>(languagesData)

export type UserLang = typeof langs[number]

// Generated with https://w.wiki/5cVs
const rtlLang = new Set([ 'ace', 'ady', 'aeb', 'ar', 'arc', 'arq', 'ary', 'arz', 'az', 'bej', 'bjn', 'bm', 'bqi', 'bsk', 'ckb', 'dar', 'diq', 'dv', 'ett', 'fa', 'ff', 'glk', 'ha', 'hbo', 'he', 'jv', 'kbd', 'khw', 'kk', 'kr', 'ks', 'ku', 'kum', 'ky', 'lad', 'lki', 'lrc', 'luz', 'min', 'ms', 'mzn', 'non', 'nqo', 'ota', 'otk', 'pa', 'pnb', 'ps', 'qya', 'rif', 'sd', 'sdh', 'shi', 'shy', 'sw', 'syc', 'ta', 'tg', 'tk', 'tru', 'tzm', 'ug', 'uz', 'uzs', 'wbl', 'wo', 'xpu' ])

export const getTextDirection = lang => {
  const languageFamilyCode = lang.split('-')[0]
  return rtlLang.has(languageFamilyCode) ? 'rtl' : 'ltr'
}
