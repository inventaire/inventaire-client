import { clone } from 'underscore'
import wdLang from 'wikidata-lang'
import log_ from '#lib/loggers'

export default (availableLangs, selectedLang) => {
  return availableLangs
  .map(lang => {
    let langObj = wdLang.byCode[lang]
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
