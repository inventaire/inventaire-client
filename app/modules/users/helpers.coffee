error_ = require 'lib/error'

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

    getProfilePicFromUserId: (id)->
      if id is app.user.id then return app.user.get 'picture'

      userModel = app.users.byId(id)
      if userModel? then userModel.get 'picture'
      else console.warn "couldnt find the user from id: #{id}"

    searchUsers: (text)->
      unless text? and text isnt ''
        return app.users.filtered.friends()

      app.users.data.remote.search(text)
      .then (res)->
        # Need to waitForData as isntAlreadyHere can't
        # do it's job if user relations data haven't return yet
        app.request('waitForData')
        .then addSearchedUsers.bind(null, text, res)

      .catch _.Error('searchUsers err')

    isMainUser: (userId)->
      if userId? then return userId is app.user.id

    isFriend: (userId)->
      unless userId? and app.users?.friends?.list?
        _.warn user, 'isFriend isnt ready (use or recalculate after data waiters)'
        return false
      return userId in app.users.friends.list

    isPublicUser: (userId)->
      unless userId? and app.users?.public?.list?
        _.warn user, 'isPublicUser isnt ready (use or recalculate after data waiters)'
        return true
      return userId in app.users.public.list

    itemsFetched: (userModel)->
      unless _.isModel(userModel)
        error_.new 'itemsFetched expected a model', userModel
      return userModel.itemsFetched is true

    getNonFriendsIds: (usersIds)->
      _.type usersIds, 'array'
      _(usersIds).chain()
      .without app.user.id
      .reject sync.isFriend
      .value()

  sync.getUsernameFromUserId = (id)->
    return sync.getUserModelFromUserId(id)?.get('username')

  app.users.queried = []

  addSearchedUsers = (text, res)->
    res.forEach addUserUnlessHere
    app.users.queried.push text
    return app.users.filtered.filterByText text

  addUserUnlessHere = (user)->
    if isntAlreadyHere user._id then app.users.public.add user

  isntAlreadyHere = (id)->
    if app.users.byId(id)? or app.request('user:isMainUser', id) then false
    else true

  async =
    getUsersData: (ids)->
      unless ids.length > 0 then return _.preq.resolve []
      app.users.data.local.get(ids, 'collection')
      .then adders.public

    getUserModel: (id, category='public')->
      app.request('waitForData')
      .then ->
        userModel = app.request 'get:userModel:from:userId', id
        if userModel? then return userModel
        else
          app.users.data.local.get(id, 'collection')
          .then adders[category]
          .then _.property('0')
      .catch _.Error('getUserModel err')

    getGroupUserModel: (id)->
      # just adding to users.nonRelationGroupUser instead of users.public
      async.getUserModel id, 'nonRelationGroupUser'

    resolveToUserModel: (user)->
      # 'user' is either the user model or a username
      if _.isModel(user) then return _.preq.resolve(user)
      else
        username = user
        app.request('get:userModel:from:username', username)
        .then (userModel)->
          if userModel? then return userModel
          else throw new Error("user model not found: #{user}")

    getUserModelFromUsername: (username)->
      if username is app.user.get('username')
        return _.preq.resolve(app.user)

      userModel = app.users.findWhere {username: username}
      if userModel? then return _.preq.resolve userModel
      else
        app.users.data.remote.findOneByUsername username
        .then (user)->
          if user?
            userModel = app.users.public.add user
            return userModel




  adders =
    # usually users not found locally are non-friends users
    public: app.users.public.add.bind(app.users.public)
    nonRelationGroupUser: app.users.nonRelationGroupUser.add.bind(app.users.nonRelationGroupUser)

  return reqresHandlers =
    'get:user:model': async.getUserModel
    'get:group:user:model': async.getGroupUserModel
    'get:users:data': async.getUsersData
    'resolve:to:userModel': async.resolveToUserModel
    'get:userModel:from:username': async.getUserModelFromUsername
    'get:userModel:from:userId': sync.getUserModelFromUserId
    'get:username:from:userId': sync.getUsernameFromUserId
    'get:userId:from:username': sync.getUserIdFromUsername
    'get:profilePic:from:userId': sync.getProfilePicFromUserId
    'get:non:friends:ids': sync.getNonFriendsIds
    'users:search': sync.searchUsers
    'user:isMainUser': sync.isMainUser
    'user:isFriend': sync.isFriend
    'user:isPublicUser': sync.isPublicUser
    'user:itemsFetched': sync.itemsFetched
