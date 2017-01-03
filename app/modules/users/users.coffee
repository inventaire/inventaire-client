fetchRelationsData = require './fetch_relations_data'

module.exports =
  define: (module, app, Backbone, Marionette, $, _)->

  initialize: ->
    app.users = require('./users_collections')(app)

    require('./helpers')(app)
    require('./requests')(app, _)
    require('./invitations')(app, _)

    app.commands.setHandlers
      'show:user': app.Execute 'show:inventory:user'
      'friend:fetchItems': fetchFriendItems

    if app.user.loggedIn
      _.preq.get app.API.relations
      .then (relations)-> app.relations = relations
      .then fetchFriendsAndTheirItems
      .catch _.Error('relations init err')
    else
      app.execute 'waiter:resolve', 'users'
      app.execute 'waiter:resolve', 'friends:items'

fetchFriendsAndTheirItems = ->
  fetchRelationsData()
  .then fetchRelationsDataSuccess
  .catch _.Error('fetchFriendsAndTheirItems err')

fetchRelationsDataSuccess = (relationsData)->
  { friends, nonRelationGroupUser } = relationsData.lists
  if friends.length is 0 and nonRelationGroupUser.length is 0
    # triggers events related to fetching relations user and item data
    app.execute 'friends:zero'
  spreadRelationsData relationsData
  app.execute 'waiter:resolve', 'users'
  fetchItemsOnNewFriend()

# tightly coupled to users_data spreadRelationsData
spreadRelationsData = (relationsData)->
  { lists, inGroups } = relationsData
  # _.log lists, 'lists'
  # _.log inGroups, 'inGroups'
  for status, usersData of lists
    for userData in usersData
      addUser inGroups, status, userData


addUser = (inGroups, status, user)->
  userModel = app.users[status].add user

  # there are possibly intersections between non-friends relations
  # (userRequested and otherRequested) and group users
  # we need to fetch items for non-friends relations in groups
  if status in possiblyInGroups
    unless userModel.id in inGroups[status]
      userModel.itemsFetched = false
      return

  userModel.itemsFetched = true
  app.execute 'friend:fetchItems', userModel

possiblyInGroups = [
  'userRequested'
  'otherRequested'
]

fetchItemsOnNewFriend = ->
  app.users.friends.on 'add', (friend)->
    app.execute 'friend:fetchItems', friend
    app.request 'show:inventory:user', friend

# do not just bind app.items.fetchFriendItems
# as app.items might not be defined yet
fetchFriendItems = (userModel)->
  app.items.fetchFriendItems userModel

removeContactItems = ->
  return app.items.friends.remove(app.items.friends.where({owner: @id}))
