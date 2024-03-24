import log_ from '#lib/loggers'
import wdLang from 'wikidata-lang'

export default (availableLangs, selectedLang) => {
  return availableLangs
  .map(lang => {
    let langObj = wdLang.byCode[lang]
    if (langObj == null) {
      log_.warn(`lang not found in wikidata-lang: ${lang}`)
      langObj = { code: lang, label: lang, native: lang }
    }

    langObj = _.clone(langObj)
    if (langObj.code === selectedLang) langObj.selected = true
    return langObj
  })
  .sort(alphabetically)
}

const alphabetically = (a, b) => a.code > b.code ? 1 : -1
