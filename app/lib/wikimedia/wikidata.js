export default // Unprefixify both entities ('item' in Wikidata lexic) and properties
{unprefixify(value){ return value?.replace(/^wdt?:/, ''); }};
