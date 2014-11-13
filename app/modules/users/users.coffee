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
    'contact:fetchItems': (userModel)-> fetchContactItems.call userModel
    # 'contact:removeItems': (userModel)-> removeContactItems.call userModel

fetchFriendsAndTheirItems = ->
  app.users.data.fetchRelationsData()
  .then (relationsData)->

    # FRIENDS
    relationsData.friends.forEach (friend)->
      userModel = app.users.friends.add friend
      userModel.following = true
      # trigger 'change:following' to update ui (ex: user_li)
      userModel.trigger 'change:following', userModel
      app.execute 'contact:fetchItems', userModel
    app.users.fetched = true
    app.vent.trigger 'users:ready'

    # REQUESTED: todo with the friend request menu

  .catch (err)->
    _.log err, 'get err'
    throw new Error('get', err.stack or err)



fetchContactItems = ->
  username = @get('username')
  _.preq.get app.API.users.items(@id)
  .then (res)->
    res.forEach (item)->
      itemModel = Items.friends.add item
      itemModel.username = username

removeContactItems = ->
  return Items.friends.remove(Items.friends.where({owner: @id}))