error_ = require 'lib/error'
usersData = require './users_data'
Users = require 'modules/users/collections/users'

module.exports = (app)->
  sync =
    getUserModelFromUserId: (id)->
      if id is app.user.id then return app.user

      userModel = app.users.byId id
      if userModel? then userModel
      else return

  async =
    fetchUsersData: (ids)->
      unless ids.length > 0 then return Promise.resolve []

      missingIds = _.difference ids, app.users.allIds()

      usersData.get missingIds, 'collection'
      .then addUsers

    getUserModel: (id, refresh)->
      if id is app.user.id then return Promise.resolve app.user

      model = app.users.byId id
      if model? and not refresh then Promise.resolve model
      else
        usersData.get id, 'collection'
        .then addUser

    getUsersModels: (ids)->
      foundUsersModels = []
      missingUsersIds = []
      for id in ids
        userModel = app.request 'get:userModel:from:userId', id
        if userModel? then foundUsersModels.push userModel
        else missingUsersIds.push id

      if missingUsersIds.length is 0
        Promise.resolve foundUsersModels
      else
        usersData.get missingUsersIds, 'collection'
        .then addUsers
        .then (newUsersModels)-> foundUsersModels.concat newUsersModels

    resolveToUserModel: (user)->
      # 'user' is either the user model, a user id, or a username
      if _.isModel(user) then return Promise.resolve user
      else
        if _.isUserId user
          userId = user
          promise = app.request 'get:user:model', userId
        else
          username = user
          promise = getUserModelFromUsername username

        promise
        .then (userModel)->
          if userModel? then return userModel
          else throw error_.new 'user model not found', 404, user

    getUserIdFromUsername: (username)->
      getUserModelFromUsername username
      .then (userModel)-> userModel.get '_id'

  getUserModelFromUsername = (username)->
    username = username.toLowerCase()
    if app.user.loggedIn and username is app.user.get('username').toLowerCase()
      return Promise.resolve app.user

    userModel = app.users.find (model)->
      model.get('username').toLowerCase() is username.toLowerCase()

    if userModel? then return Promise.resolve userModel

    usersData.byUsername username
    .then addUser

  addUsers = (users)->
    users = _.forceArray(users).filter isntMainUser
    # Set merge=true so that updates arriving here aren't just ignored
    return app.users.add users, { merge: true }

  addUser = (users)-> addUsers(users)[0]

  { searchByText, searchByPosition } = require('./lib/search')(app)

  app.reqres.setHandlers
    'get:user:model': async.getUserModel
    'get:users:models': async.getUsersModels
    'fetch:users:data': async.fetchUsersData
    'resolve:to:userModel': async.resolveToUserModel
    'get:userModel:from:userId': sync.getUserModelFromUserId
    'get:userId:from:username': async.getUserIdFromUsername
    'users:search': searchByText
    'users:search:byPosition': searchByPosition
    'user:add': addUser

  app.commands.setHandlers
    'users:add': addUsers

  return

isntMainUser = (user)-> user._id isnt app.user.id
