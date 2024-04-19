import app from '#app/app'
import { serverReportError } from '#app/lib/error'
import preq from '#app/lib/preq'
import { searchWikidataEntities } from '#app/lib/wikimedia/wikidata'

// Uses wbsearchentities despite its lack of inter-languages support
// because it returns hits labels, descriptions and aliases
// while action=query&list=search&srsearch returns only hits ids
export async function wikidataSearch ({ search, limit = 10, offset, formatResults = false }) {
  const res = await preq.get(searchWikidataEntities({ search, limit, offset }))
  let { search: results, 'search-continue': continu } = res
  if (results) {
    results = results.filter(filterOutSpecialPages)
    if (formatResults) results = results.map(formatAsSearchResult)
  } else {
    serverReportError('wikidata search returned no results', { search, res })
    results = []
  }
  return { results, continue: continu }
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
  const { id, label, description, aliases } = result
  result.uri = `wd:${id}`
  result.labels = {}
  result.labels[lang] = label
  result.descriptions = {}
  result.descriptions[lang] = description
  // overriding the array of aliases
  result.aliases = {}
  result.aliases[lang] = aliases
  return result
}
