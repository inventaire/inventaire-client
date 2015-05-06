module.exports =
  define: (module, app, Backbone, Marionette, $, _) ->

  initialize: ->
    app.users = require('./users_collections')(app)
    app.users.data = require('./users_data')(app, $, _)

    helpers = require('./helpers')(app)
    requests = require('./requests')(app, _)

    app.reqres.setHandlers _.extend(helpers, requests)

    initUsersItems()
    app.request('waitForUserData').then fetchFriendsAndTheirItems

initUsersItems = ->
  app.commands.setHandlers
    'show:user': (username)-> app.execute 'show:inventory:user', username
    'friend:fetchItems': (userModel)-> fetchFriendItems(userModel)
    # 'contact:removeItems': (userModel)-> removeContactItems.call userModel

fetchFriendsAndTheirItems = ->
  if app.user.loggedIn
    app.users.data.fetchRelationsData()
    .then (relationsData)->
      if relationsData.friends.length is 0
        app.execute 'friends:zero'
      relationsData.friends.forEach addFriend
      relationsData.otherRequested.forEach addOther
      relationsData.userRequested.forEach addUserRequested
      app.users.fetched = true
      app.vent.trigger 'users:ready'

      fetchItemsOnNewFriend()

    .catch (err)-> _.error err, 'fetchFriendsAndTheirItems err'
  else
    app.users.fetched = true
    app.vent.trigger 'users:ready'

fetchItemsOnNewFriend = ->
  app.users.friends.on 'add', (friend)->
    app.execute 'friend:fetchItems', friend
    app.request 'show:inventory:user', friend

addFriend = (friend)->
  userModel = app.users.friends.add friend
  app.execute 'friend:fetchItems', userModel

addOther = (other)->
  userModel = app.users.otherRequested.add other

addUserRequested = (user)->
  userModel = app.users.userRequested.add user

fetchFriendItems = (userModel)->
  Items.friends.fetchFriendItems(userModel)

removeContactItems = ->
  return Items.friends.remove(Items.friends.where({owner: @id}))