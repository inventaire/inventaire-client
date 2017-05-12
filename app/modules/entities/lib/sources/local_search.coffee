module.exports = (type)-> (search)->
  _.preq.get app.API.entities.searchLocal(type, search)
  .map formatResult

formatResult = (result)->
  result.id = result._id
  return result
