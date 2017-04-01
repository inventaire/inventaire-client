wdLang = require 'wikidata-lang'
error_ = require 'lib/error'

module.exports = (availableLangs, selectedLang)->
  availableLangs
  .map (lang)->
    langObj = wdLang.byCode[lang]
    unless langObj?
      error_.report "lang not found in wikidata-lang: #{lang}"
      langObj = { code: lang, label: lang, native: lang }

    langObj = _.clone langObj
    if langObj.code is selectedLang then langObj.selected = true
    return langObj
