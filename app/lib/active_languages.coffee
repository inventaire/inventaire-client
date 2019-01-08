wdLang = require 'wikidata-lang'

languages = require './languages_data'

regionify = {}

for lang, obj of languages
  obj.lang = lang
  obj.native = wdLang.byCode[lang].native
  regionify[lang] = obj.defaultRegion

langs = Object.keys languages

module.exports = { languages, langs, regionify }
