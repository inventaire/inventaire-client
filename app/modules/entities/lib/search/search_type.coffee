wdk = require 'lib/wikidata-sdk'

module.exports = (type)-> (search, limit)->
  _.preq.get app.API.entities.searchType(type, search, limit)
  .get 'results'
  .map formatResult

formatResult = (result)->
  result.id or= result._id
  { id } = result
  result.uri or= if wdk.isWikidataItemId(id) then "wd:#{id}" else "inv:#{id}"
  return result
