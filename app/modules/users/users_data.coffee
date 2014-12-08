module.exports = (app, $, _)->
  remoteData =
    get: (ids)-> _.preq.get app.API.users.data(ids)
    search: (text)->
      # catches case with ''
      if _.isEmpty(text) then return $.Deferred().resolve([])
      else return _.preq.get app.API.users.search(text)

  localData = new app.LocalCache
    name: 'users'
    remoteDataGetter: remoteData.get
    parseData: (data)-> data.users


  fetchRelationsData = ->
    relations = app.user.relations
    _.log relations, 'relations:all'
    ids = _.allValues(relations)
    _.log ids, 'relations:fetchRelationsData ids'
    return localData.get(ids)
    .then (data)-> spreadRelationsData(data, relations)

  spreadRelationsData = (data, relations)->
    relationsData =
      friends: []
      userRequests: []
      othersRequests: []

    for relationType, list of relations
      list.forEach (user)->
        relationsData[relationType].push data[user]
    return relationsData

  return data =
    remote: remoteData
    local: localData
    fetchRelationsData: fetchRelationsData