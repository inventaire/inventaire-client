import wdLang from 'wikidata-lang'
const languages = _.values(wdLang.byCode)

export default function (query) {
  query = query.toLowerCase()

  // If the query matches a lang code, only return the matching language
  const codeLang = wdLang.byCode[query]
  if (codeLang != null) return Promise.resolve([ formatAsSearchResult(codeLang) ])

  const re = new RegExp(query, 'i')
  // one more reason to move to Lodash asap, this would really need lazy evaluation
  const results = _.chain(languages)
    .filter(language => {
      if (language.label.match(re)) return true
      if (language.native.match(re)) return true
      return false
    }).first(10)
    .map(formatAsSearchResult)
    .value()

  return Promise.resolve(results)
}

const formatAsSearchResult = function (result) {
  if (result._formatted) return result
  result._formatted = true
  result.id = result.wd
  result.aliases = {}
  result.labels = { en: result.label }
  result.labels[result.code] = result.native
  return result
}
