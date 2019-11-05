wdLang = require 'wikidata-lang'

module.exports = (availableLangs, selectedLang)->
  availableLangs
  .map (lang)->
    langObj = wdLang.byCode[lang]
    unless langObj?
      _.warn "lang not found in wikidata-lang: #{lang}"
      langObj = { code: lang, label: lang, native: lang }

    langObj = _.clone langObj
    if langObj.code is selectedLang then langObj.selected = true
    return langObj
