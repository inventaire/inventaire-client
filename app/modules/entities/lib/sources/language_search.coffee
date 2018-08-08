wdLang = require 'wikidata-lang'
languages = _.values wdLang.byCode

module.exports = (query)->
  query = query.toLowerCase()

  # If the query matches a lang code, only return the matching language
  codeLang = wdLang.byCode[query]
  if codeLang? then return _.preq.resolve [ formatAsSearchResult(codeLang) ]

  re = new RegExp query, 'i'
  # one more reason to move to Lodash asap, this would really need lazy evaluation
  results = _.chain languages
    .filter (language)->
      if language.label.match(re) then return true
      if language.native.match(re) then return true
      return false
    .first 10
    .map formatAsSearchResult
    .value()

  _.preq.resolve results

formatAsSearchResult = (result)->
  if result._formatted then return result
  result._formatted = true
  result.id = result.wd
  result.aliases = {}
  result.labels = { en: result.label }
  result.labels[result.code] = result.native
  return result
