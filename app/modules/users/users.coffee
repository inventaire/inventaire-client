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
      # 'friend:fetchItems': fetchFriendItems

    if app.user.loggedIn
      _.preq.get app.API.relations
      .then (relations)-> app.relations = relations
      .then fetchFriends
      .catch _.Error('relations init err')
    else
      app.execute 'waiter:resolve', 'users'

fetchFriends = ->
  fetchRelationsData()
  .then fetchRelationsDataSuccess
  .catch _.Error('fetchFriends err')

fetchRelationsDataSuccess = (relationsData)->
  spreadRelationsData relationsData
  app.execute 'waiter:resolve', 'users'
  showNewFriendInventoryOnAdd()

# tightly coupled to users_data spreadRelationsData
spreadRelationsData = (relationsData)->
  { lists, inGroups } = relationsData
  for status, usersData of lists
    for userData in usersData
      addUser inGroups, status, userData

addUser = (inGroups, status, user)-> app.users[status].add user

possiblyInGroups = [
  'userRequested'
  'otherRequested'
]

# TODO: trigger from the 'accept' friend request click event
showNewFriendInventoryOnAdd = ->
  app.users.friends.on 'add', app.Request('show:inventory:user')
