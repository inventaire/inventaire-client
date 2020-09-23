/* eslint-disable
    implicit-arrow-linebreak,
    import/no-duplicates,
    no-undef,
    no-var,
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
import wdk from 'lib/wikidata-sdk'

export default (format = true) => (search, limit = 10, offset) => // Uses wbsearchentities despite its lack of inter-languages support
// because it returns hits labels, descriptions and aliases
// while action=query&list=search&srsearch returns only hits ids
  _.preq.get(wdk.searchEntities({ search, limit, offset }))
.get('search')
.filter(filterOutSpecialPages)
.then(results => {
  if (format) {
    return results.map(formatAsSearchResult)
  } else { return results }
})

// This is a hacky way to filter out special pages without having to request claims
const specialPagesDescriptionPattern = /(Wikim(e|é)dia|Wikip(e|é)dia)/
var filterOutSpecialPages = function (result) {
  if (!result.description) { result.description = '' }
  return !result.description.match(specialPagesDescriptionPattern)
}

// make the result match the needs of app/modules/entities/models/search_result
var formatAsSearchResult = function (result) {
  const { lang } = app.user
  const { label, description, aliases } = result
  result.labels = {}
  result.labels[lang] = label
  result.descriptions = {}
  result.descriptions[lang] = description
  // overriding the array of aliases
  result.aliases = {}
  result.aliases[lang] = aliases
  return result
}
