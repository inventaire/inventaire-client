/* eslint-disable
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
export default // Unprefixify both entities ('item' in Wikidata lexic) and properties
{ unprefixify (value) { return value?.replace(/^wdt?:/, '') } }
