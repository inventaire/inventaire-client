wdLang = require 'wikidata-lang'
{ formatLabel } = require 'lib/wikimedia/wikidata'

languages = require './languages_data'

regionify = {}

for lang, obj of languages
  obj.lang = lang
  obj.native = formatLabel wdLang.byCode[lang].native
  regionify[lang] = obj.defaultRegion

langs = Object.keys languages

module.exports = { languages, langs, regionify }
