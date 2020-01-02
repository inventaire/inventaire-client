module.exports =
  # Unprefixify both entities ('item' in Wikidata lexic) and properties
  unprefixify: (value)-> value?.replace /^wdt?:/, ''
