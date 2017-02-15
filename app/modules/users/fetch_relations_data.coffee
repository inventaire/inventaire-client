usersData = require './users_data'

module.exports = ->
  app.request 'wait:for', 'groups'
  .then _fetchRelationsData

_fetchRelationsData = ->
  { groups } = app
  # Using a different object than app.relations, so that adding coGroupMembers
  # doesn't make spreadRelationsData loop on relations crash
  relations = _.deepClone app.relations
  unless relations? or groups?
    return _.preq.reject 'no relations found at fetchRelationsData'

  relationsIds = _.allValues relations
  groupsIds = extractGroupsIds groups

  app.relations.coGroupMembers = groupsIds

  relations.nonRelationGroupUser = _.difference groupsIds, relationsIds
  inGroups = inGroupsNonFriendsRelations relations, groupsIds
  networkIds = _.union relationsIds, groupsIds

  usersData.get networkIds
  .then spreadRelationsData.bind(null, relations, inGroups)

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

  for relationType, list of relations
    for userId in list
      userData = data[userId]
      lists[relationType].push userData

  return relationsData =
    lists: lists
    inGroups: inGroups

extractGroupsIds = (groups)->
  _.chain(groups.models)
  .map concatGroupIds
  .flatten()
  .uniq()
  .without app.user.id
  .value()

concatGroupIds = (group)-> group.allMembersIds()
