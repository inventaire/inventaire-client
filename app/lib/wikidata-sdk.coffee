# A tree-shaked version of wikidata-sdk to fit the client's exact needs
# https://github.com/maxlath/wikidata-sdk

{ buildPath } = require 'lib/location'

module.exports =
  searchEntities: (params)->
    { search, limit, offset } = params

    unless search?.length > 0 then throw new Error "search can't be empty"

    { lang } = app.user

    return buildPath 'https://www.wikidata.org/w/api.php',
      action: 'wbsearchentities'
      search: search
      language: lang
      uselang: lang
      limit: limit
      continue: offset
      format: 'json'
      origin: '*'

  isWikidataItemId: (id)-> /^Q[0-9]+$/.test id
  isWikidataPropertyId: (id)-> /^P[0-9]+$/.test id
