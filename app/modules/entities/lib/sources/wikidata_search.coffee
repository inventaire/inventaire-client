wdk = require 'lib/wikidata-sdk'

module.exports = (query)->
  # Uses wbsearchentities despite its lack of inter-languages support
  # because it returns hits labels, descriptions and aliases
  # while action=query&list=search&srsearch returns only hits ids
  _.preq.get wdk.searchEntities(query, app.user.lang, 10)
  .then parse
  .then _.Log('wikidata search parsed results')

parse = (res)->
  res.search
  .map formatAsSearchResult
  # .filter removeDesambiguationPages

# make the result match the needs of app/modules/entities/models/search_result
formatAsSearchResult = (result)->
  { lang } = app.user
  { label, description, aliases } = result
  result.labels = {}
  result.labels[lang] = label
  result.descriptions = {}
  result.descriptions[lang] = description
  # overriding the array of aliases
  result.aliases = {}
  result.aliases[lang] = aliases
  return result
