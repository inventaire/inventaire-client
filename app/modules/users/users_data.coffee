module.exports = (app, $, _)->
  remote =
    get: (ids)->
      _.preq.get app.API.users.data(ids)
      .catch (err)-> _.logXhrErr err, 'users_data get err'

    search: (text)->
      # catches case with ''
      if _.isEmpty(text) then return _.preq.resolve([])

      _.preq.get app.API.users.search(text)
      .catch (err)-> _.logXhrErr err, 'users_data search err'

    findOneByUsername: (username)->
      @search(username)
      .then (res)->
        user = res?[0]
        if user?.username is username then return user


  localData = new app.LocalCache
    name: 'users'
    remote: remote
    parseData: (data)-> data.users


  fetchRelationsData = ->
    relations = app.user.relations
    if relations?
      _.log relations, 'relations:all'
      ids = _.allValues(relations)
      _.log ids, 'relations:fetchRelationsData ids'
      return localData.get(ids)
      .then (data)-> spreadRelationsData(data, relations)
    else return _.preq.reject 'no relations found at fetchRelationsData'

  spreadRelationsData = (data, relations)->
    relationsData =
      friends: []
      userRequested: []
      otherRequested: []

    for relationType, list of relations
      list.forEach (user)->
        relationsData[relationType].push data[user]
    return relationsData

  return data =
    remote: remote
    local: localData
    fetchRelationsData: fetchRelationsData