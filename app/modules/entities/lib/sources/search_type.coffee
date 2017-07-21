searchType = (index)-> (type)-> (search)->
  _.preq.get app.API.entities.searchType(index, type, search)
  .map formatResult

formatResult = (result)->
  result.id or= result._id
  return result

module.exports =
  wikidata: searchType 'wikidata'
  inventaire: searchType 'inventaire'
