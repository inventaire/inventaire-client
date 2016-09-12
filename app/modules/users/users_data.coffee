localCache = require 'lib/data/local_cache'

module.exports = (app, $, _)->
  remote = require('./lib/remote_queries')(app, _)
  localData = localCache
    name: 'users'
    remote: remote
    parseData: _.property 'users'

  fetchRelationsData = ->
    app.request 'wait:for', 'groups'
    .then _fetchRelationsData

  _fetchRelationsData = ->
    { relations, groups } = app
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
      for userId in list
        userData = data[userId]
        lists[relationType].push userData

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

concatGroupIds = (group)-> group.allMembersIds()
