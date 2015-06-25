module.exports = (app)->
  sync =
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

      userModel = app.users.findWhere({username: username})
      if userModel? then return _.preq.resolve(userModel)
      else
        app.users.data.remote.findOneByUsername(username)
        .then (user)->
          if user?
            userModel = app.users.public.add(user)
            return userModel

    getUserModelFromUserId: (id)->
      if id is app.user.id then return app.user

      userModel = app.users.byId(id)
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
      if text? and text isnt ''
        app.users.data.remote.search(text)
        .then (res)->
          _.log res, 'searchUsers res'
          callback = (res)->
            res.forEach (user)->
              app.users.public.add(user) if isntAlreadyHere(user._id)
            app.users.queried.push(text)
            return app.users.filtered.filterByText(text)
          # Need to waitForData as isntAlreadyHere can't
          # do it's job if user relations data haven't return yet
          app.request('waitForData').then callback.bind(null, res)
        .fail _.error
      else
        app.users.filtered.friends()

    isMainUser: (userId)->
      if userId? then return userId is app.user.id

    isFriend: (userId)->
      unless userId? and app.users?.friends?.list? then return false
      return userId in app.users.friends.list

    isPublicUser: (userId)->
      if userId? then return userId in app.users.public.list

  sync.getUsernameFromUserId = (id)->
    return sync.getUserModelFromUserId(id)?.get('username')

  app.users.queried = []

  isntAlreadyHere = (id)->
    if app.users.byId(id)? or app.request('user:isMainUser', id) then false
    else true

  async =
    getUsersData: (ids)->
      app.users.data.local.get(ids, 'collection')
      .then addPublicUsers

    getUserModel: (id)->
      app.request('waitForData')
      .then ->
        userModel = app.request 'get:userModel:from:userId', id
        if userModel? then return userModel
        else
          app.users.data.local.get(id, 'collection')
          .then addPublicUsers
          .then _.property('0')
      .catch _.Error('getUserModel err')


  addPublicUsers = (users)->
    # usually users not found locally are non-friends users
    app.users.public.add users

  return reqresHandlers =
    'resolve:to:userModel': sync.resolveToUserModel
    'get:user:model': async.getUserModel
    'get:users:data': async.getUsersData
    'get:userModel:from:userId': sync.getUserModelFromUserId
    'get:userModel:from:username': sync.getUserModelFromUsername
    'get:username:from:userId': sync.getUsernameFromUserId
    'get:userId:from:username': sync.getUserIdFromUsername
    'get:profilePic:from:userId': sync.getProfilePicFromUserId
    'users:search': sync.searchUsers
    'user:isMainUser': sync.isMainUser
    'user:isFriend': sync.isFriend
    'user:isPublicUser': sync.isPublicUser
