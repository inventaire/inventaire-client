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
    'friend:fetchItems': (userModel)-> fetchContactItems.call userModel
    # 'contact:removeItems': (userModel)-> removeContactItems.call userModel

fetchFriendsAndTheirItems = ->
  app.users.data.fetchRelationsData()
  .then (relationsData)->
    relationsData.friends.forEach addFriend
    relationsData.othersRequests.forEach addOther
    relationsData.userRequests.forEach addUserRequests
    app.users.fetched = true
    app.vent.trigger 'users:ready'

  .catch (err)->
    _.error new Error(err), 'fetchFriendsAndTheirItems err'

addFriend = (friend)->
  userModel = app.users.friends.add friend
  app.execute 'friend:fetchItems', userModel

addOther = (other)->
  userModel = app.users.othersRequests.add other

addUserRequests = (user)->
  userModel = app.users.userRequests.add user

fetchContactItems = ->
  username = @get('username')
  _.preq.get app.API.users.items(@id)
  .then (res)->
    res.forEach (item)->
      itemModel = Items.friends.add item
      itemModel.username = username

removeContactItems = ->
  return Items.friends.remove(Items.friends.where({owner: @id}))