wdLang = require 'wikidata-lang'

# defaultRegions are needed for 'og:locale' and 'og:locale:alternate'
# that seem to snob 2 letters languages

languages = require './languages_data'

regionify = {}

for lang, obj of languages
  obj.lang = lang
  console.log('lang', lang, wdLang.byCode[lang])
  obj.native = wdLang.byCode[lang].native
  regionify[lang] = obj.defaultRegion

module.exports =
  languages: languages
  langs: Object.keys languages
  regionify: regionify
