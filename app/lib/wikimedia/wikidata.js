// Unprefixify both entities ('item' in Wikidata lexic) and properties
export const unprefixify = value => value?.replace(/^wdt?:/, '')
