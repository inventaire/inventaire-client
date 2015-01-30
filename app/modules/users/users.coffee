module.exports =
  define: (module, app, Backbone, Marionette, $, _) ->

  initialize: ->
    app.users = require('./users_collections')(app)
    app.users.data = require('./users_data')(app, $, _)

    helpers = require('./helpers')(app)
    requests = require('./requests')(app, _)

    app.reqres.setHandlers _.extend(helpers, requests)

    initUsersItems()
    app.request 'waitForUserData', fetchFriendsAndTheirItems

initUsersItems = ->
  app.commands.setHandlers
    'show:user': (username)-> app.execute 'show:inventory:user', username
    'friend:fetchItems': (userModel)-> fetchFriendItems(userModel)
    # 'contact:removeItems': (userModel)-> removeContactItems.call userModel

  app.reqres.setHandlers
    'get:users:data': (ids)->
      app.users.data.local.get(ids, 'collection')
      .then (users)->
        # usually users not found locally are non-friends users
        app.users.public.add users

fetchFriendsAndTheirItems = ->
  if app.user.loggedIn
    app.users.data.fetchRelationsData()
    .then (relationsData)->
      relationsData.friends.forEach addFriend
      relationsData.otherRequested.forEach addOther
      relationsData.userRequested.forEach addUserRequested
      app.users.fetched = true
      app.vent.trigger 'users:ready'

    .catch (err)->
      _.error err, 'fetchFriendsAndTheirItems err'
  else
    app.users.fetched = true
    app.vent.trigger 'users:ready'

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