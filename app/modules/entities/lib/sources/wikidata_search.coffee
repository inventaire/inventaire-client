wdk = require 'lib/wikidata-sdk'

module.exports = (query, format=true)->
  # Uses wbsearchentities despite its lack of inter-languages support
  # because it returns hits labels, descriptions and aliases
  # while action=query&list=search&srsearch returns only hits ids
  _.preq.get wdk.searchEntities(query, app.user.lang, 10)
  .get 'search'
  .filter filterOutSpecialPages
  .then (results)->
    if format then results.map formatAsSearchResult
    else results
  .then _.Log('wikidata search parsed results')

# This is a hacky way to filter out special pages without having to request claims
specialPagesDescriptionPattern = /(Wikim(e|é)dia|Wikip(e|é)dia)/
filterOutSpecialPages = (result) ->
  result.description or= ''
  return not result.description.match specialPagesDescriptionPattern

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
