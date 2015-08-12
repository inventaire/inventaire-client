module.exports = (app, $, _)->
  remote =
    get: (ids)->
      _.preq.get app.API.users.data(ids)
      .catch _.LogXhrErr('users_data get err')

    search: (text)->
      # catches case with ''
      if _.isEmpty(text) then return _.preq.resolve []

      _.preq.get app.API.users.search(text)
      .catch _.LogXhrErr('users_data search err')

    findOneByUsername: (username)->
      @search(username)
      .then (res)->
        user = res?[0]
        # ignoring case as the user database does
        if user?.username.toLowerCase() is username.toLowerCase()
          return user


  localData = new app.LocalCache
    name: 'users'
    remote: remote
    parseData: _.property 'users'


  fetchRelationsData = ->
    { relations, groups } = app.user
    unless relations? or groups?
      return _.preq.reject 'no relations found at fetchRelationsData'

    relationsIds = _.allValues relations
    groupsIds = extractGroupsIds groups

    relations.nonRelationGroupUser = _.difference groupsIds, relationsIds
    inGroups = inGroupsNonFriendsRelations relations, groupsIds
    networkIds = _.union relationsIds, groupsIds

    localData.get networkIds
    .then spreadRelationsData.bind(null, relations, inGroups)
    # .then _.Log('spreaded')

  inGroupsNonFriendsRelations = (relations, groupsIds)->
    # including possible userRequested and otherRequested users
    # will be used to fetch all their items
    userRequested: _.intersection groupsIds, relations.userRequested
    otherRequested: _.intersection groupsIds, relations.otherRequested

  spreadRelationsData = (relations, inGroups, data)->
    lists =
      friends: []
      userRequested: []
      otherRequested: []
      nonRelationGroupUser: []

    # _.log relations, 'relations'

    for relationType, list of relations
      list.forEach (userId)->
        userData = data[userId]
        lists[relationType].push userData
    # return relationsData
    return relationsData =
      lists: lists
      inGroups: inGroups

  return data =
    remote: remote
    local: localData
    fetchRelationsData: fetchRelationsData

extractGroupsIds = (groups)->
  _.chain(groups.models)
  .map concatGroupIds
  .flatten()
  .uniq()
  .without app.user.id
  .value()

concatGroupIds = (group)-> group.allMembers()
