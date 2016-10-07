wdLang = require 'wikidata-lang'
{ formatLabel } = require 'lib/wikimedia/wikidata'

# defaultRegions are needed for 'og:locale' and 'og:locale:alternate'
# that seem to snob 2 letters languages

languages = require './languages_data'

regionify = {}

for lang, obj of languages
  obj.lang = lang
  obj.native = formatLabel wdLang.byCode[lang].native
  regionify[lang] = obj.defaultRegion

module.exports =
  languages: languages
  langs: Object.keys languages
  regionify: regionify
