import wdLang from 'wikidata-lang'
import languages from './languages_data.js'

export const regionify = {}

for (const lang in languages) {
  const obj = languages[lang]
  obj.lang = lang
  obj.native = wdLang.byCode[lang].native
  regionify[lang] = obj.defaultRegion
}

export const langs = Object.keys(languages)

const rtlLang = [ 'ar', 'he' ]

export const getTextDirection = lang => rtlLang.includes(lang) ? 'rtl' : 'ltr'
