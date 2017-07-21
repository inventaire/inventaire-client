module.exports = (type)-> (search)->
  _.preq.get app.API.entities.searchType(type, search)
  .map formatResult

formatResult = (result)->
  result.id or= result._id
  return result
