module.exports =
  # Unprefixify both entities ('item' in Wikidata lexic) and properties
  unprefixify: (value)-> value?.replace /^wdt?:/, ''

  # It sometimes happen that a Wikidata label is a direct copy of the Wikipedia
  # title, which can then have desambiguating parenthesis: we got to drop those
  formatLabel: (label)-> label.replace /\s\(.*\)$/, ''
