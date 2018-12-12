# A tree-shaked version of wikidata-sdk 4.0.6 to fit the client's exact needs
# https://github.com/maxlath/wikidata-sdk

{ buildPath } = require 'lib/location'

# Simplistic implementation to filter-out arrays
isPlainObject = (obj)->
  unless obj? then return false
  unless typeof obj is 'object' then return false
  if obj instanceof Array then return false
  return true

module.exports =
  searchEntities: (search, language, limit, format, uselang)->
    # polymorphism: arguments can be passed as an object keys
    if isPlainObject search
      { search, language, limit, format, uselang } = search

    unless search?.length > 0 then throw new Error "search can't be empty"

    language or= 'en'
    uselang or= language
    limit or= '20'
    format or= 'json'

    return buildPath 'https://www.wikidata.org/w/api.php',
      action: 'wbsearchentities'
      search: search
      language: language
      limit: limit
      format: format
      uselang: uselang
      origin: '*'

  isWikidataItemId: (id)-> /^Q[0-9]+$/.test id
  isWikidataPropertyId: (id)-> /^P[0-9]+$/.test id
