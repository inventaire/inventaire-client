wdLang = require 'wikidata-lang'
window.LANGS = languages = _.values wdLang.byCode

module.exports = window.makeQuery = (query)->
  re = new RegExp query
  # one more reason to move to Lodash asap, this would really need lazy evaluation
  results = _.chain languages
    .filter (language)-> language.label.toLowerCase().match re
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
