wdk = require 'wikidata-sdk'

module.exports = (query)->
  _.preq.get wdk.searchEntities(query, app.user.lang, 10)
  .then _.Log('res')
  .then parse
  .then _.Log('parsed')

parse = (res)->
  res.search
  .map formatAsSearchResult
  # .filter removeDesambiguationPages

# make the result match the needs of app/modules/entities/models/search_result
formatAsSearchResult = (result)->
  { lang } = app.user
  { label, aliases } = result
  result.labels = {}
  result.labels[lang] = label
  # overriding the array of aliases
  result.aliases = {}
  result.aliases[lang] = aliases
  return result