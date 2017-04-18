error_ = require 'lib/error'
usersData = require './users_data'

module.exports = (app)->
  sync =
    getUserModelFromUserId: (id)->
      if id is app.user.id then return app.user

      userModel = app.users.byId id
      if userModel? then userModel
      else return

    getUserIdFromUsername: (username)->
      if username is app.user.get('username') then return app.user.id

      userModel = app.users.findWhere({username: username})
      if userModel? then userModel.id
      else console.warn "couldnt find the user from username: #{username}"

    isMainUser: (userId)->
      if userId? then return userId is app.user.id

    isFriend: (userId)->
      unless userId? and app.users?.friends?.list?
        _.warn userId, 'isFriend isnt ready (use or recalculate after data waiters)'
        return false
      return userId in app.users.friends.list

    isPublicUser: (userId)->
      if sync.isMainUser(userId) then return false
      unless app.user.loggedIn then return true
      unless userId? and app.users?.public?.list?
        _.warn userId, 'isPublicUser isnt ready (use or recalculate after data waiters)'
        return true
      # NB: nonRelationGroupUser aren't considerer public users
      # as their user and items data are fetched as friends
      return userId in app.users.public.list

    itemsFetched: (userModel)->
      unless _.isModel(userModel)
        throw error_.new 'itemsFetched expected a model', userModel
      return userModel.itemsFetched is true

  async =
    getUsersData: (ids)->
      unless ids.length > 0 then return _.preq.resolve []

      app.request 'waitForNetwork'
      .then -> usersData.get ids, 'collection'
      .then (users)->
        compacted = _.compact users

        if compacted.length isnt ids.length
          missingIds = _.difference ids, compacted.map(_.property('_id'))
          # known cases: when a user was deleted
          # and a notification depended on his data
          _.warn missingIds, 'getUsersData missing ids'

        return compacted
      # make sure not to re-add users who have a different status than public
      .then addPublicUsers

    getUserModel: (id, category='public')->
      app.request 'waitForNetwork'
      .then ->
        userModel = app.request 'get:userModel:from:userId', id
        if userModel? then return userModel
        else
          usersData.get id, 'collection'
          .then (usersData)->
            # known case when userData.length is 0 and this throws:
            # deleted user with an id still hanging around
            unless usersData.length is 1
              throw new Error "user not found: #{id}"

            return adders[category](usersData)[0]

      .catch _.ErrorRethrow('getUserModel err')

    getUsersModels: (ids, category='public')->
      app.request 'waitForNetwork'
      .then ->
        foundUsersModels = []
        missingUsersIds = []
        for id in ids
          userModel = app.request 'get:userModel:from:userId', id
          if userModel? then foundUsersModels.push userModel
          else missingUsersIds.push id

        if missingUsersIds.length is 0 then return foundUsersModels
        else
          usersData.get missingUsersIds, 'collection'
          .then (usersData)->
            newUsersModels = adders[category](_.compact(usersData))
            return foundUsersModels.concat newUsersModels

      .catch _.ErrorRethrow('getUserModel err')

    getGroupUsersModels: (ids)->
      # just adding to users.nonRelationGroupUser instead of users.public
      async.getUsersModels ids, 'nonRelationGroupUser'

    resolveToUserModel: (user)->
      # 'user' is either the user model, a user id, or a username
      if _.isModel(user) then return _.preq.resolve user
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
          else throw new Error("user model not found: #{user}")

  getUserModelFromUsername = (username)->
    if username is app.user.get('username')
      return _.preq.resolve(app.user)

    userModel = app.users.findWhere { username }
    if userModel? then return _.preq.resolve userModel
    else
      usersData.byUsername username
      .then (user)->
        if user?
          userModel = app.users.public.add user
          return userModel

  filterOutAlreadyThere = (users)->
    current = app.users.list()
    current.push app.user.id
    return users.filter (user)-> not (user._id in current)

  addPublicUsers = (users)->
    users = _.forceArray users
    allUsersIds = users.map _.property('_id')
    users = filterOutAlreadyThere users
    app.users.public.add users
    # make sure to return all requested users models
    # and not only those that were missing
    return app.users.byIds(allUsersIds)

  # returns the user model
  addPublicUser = (user)->
    { _id } = user
    knownUser = app.users.byId _id
    if knownUser? then return knownUser
    else return app.users.public.add user

  adders =
    # usually users not found locally are non-friends users
    public: addPublicUsers
    nonRelationGroupUser: app.users.nonRelationGroupUser.add.bind(app.users.nonRelationGroupUser)

  { searchByText, searchByPosition } = require('./lib/search')(app)

  app.reqres.setHandlers
    'get:user:model': async.getUserModel
    'get:group:users:models': async.getGroupUsersModels
    'get:users:data': async.getUsersData
    'resolve:to:userModel': async.resolveToUserModel
    'get:userModel:from:username': async.getUserModelFromUsername
    'get:userModel:from:userId': sync.getUserModelFromUserId
    'get:userId:from:username': sync.getUserIdFromUsername
    'user:isMainUser': sync.isMainUser
    'user:isFriend': sync.isFriend
    'user:isPublicUser': sync.isPublicUser
    'user:itemsFetched': sync.itemsFetched
    'users:search': searchByText
    'users:search:byPosition': searchByPosition
    'user:public:add': addPublicUser

  app.commands.setHandlers
    'users:public:add': addPublicUsers

  return
