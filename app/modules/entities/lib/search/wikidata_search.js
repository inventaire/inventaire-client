import preq from 'lib/preq'
import wdk from 'lib/wikidata-sdk'

// Uses wbsearchentities despite its lack of inter-languages support
// because it returns hits labels, descriptions and aliases
// while action=query&list=search&srsearch returns only hits ids
export default (format = true) => async (search, limit = 10, offset) => {
  let { search: results } = await preq.get(wdk.searchEntities({ search, limit, offset }))
  results = search.filter(filterOutSpecialPages)
  if (format) return results.map(formatAsSearchResult)
  else return results
}

// This is a hacky way to filter out special pages without having to request claims
const specialPagesDescriptionPattern = /(Wikim(e|é)dia|Wikip(e|é)dia)/
const filterOutSpecialPages = result => {
  result.description = result.description || ''
  return !result.description.match(specialPagesDescriptionPattern)
}

// make the result match the needs of app/modules/entities/models/search_result
const formatAsSearchResult = result => {
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
