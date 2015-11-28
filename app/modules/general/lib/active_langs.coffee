# 'og:locale' and 'og:locale:alternate' seem to snob 2 letters languages
# so here is a mapping to most relevant territories
territorialize =
  de: 'de_DE'
  es: 'es_ES'
  fr: 'fr_FR'
  pl: 'pl_PL'
  sv: 'sv_SE'

# non-default langs needing
alternateLangs = Object.keys territorialize

territorialize.en = 'en_US'

module.exports =
  alternateLangs: alternateLangs
  territorialize: territorialize