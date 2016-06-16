wdLang = require 'wikidata-lang'

# defaultRegions are needed for 'og:locale' and 'og:locale:alternate'
# that seem to snob 2 letters languages

languages =
  da:
    completion: 16
    defaultRegion: 'da_DK'
  de:
    completion: 67
    defaultRegion: 'de_DE'
  en:
    completion: 100
    defaultRegion: 'en_US'
  es:
    completion: 3
    defaultRegion: 'es_ES'
  fr:
    completion: 97
    defaultRegion: 'fr_FR'
  it:
    completion: 2
    defaultRegion: 'it_ITz'
  # Letting Norvegian aside for the moment as there are conflicts in the 2 and 4 letters code used to identify the variantes:
  # Transifex: uses nb_NO, Wikimedia: nb, no, IETF: nb
  # nb:
  #   completion: 5
  #   defaultRegion: 'nb_NO'
  pl:
    completion: 8
    defaultRegion: 'pl_PL'
  sv:
    completion: 53
    defaultRegion: 'sv_SE'

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
