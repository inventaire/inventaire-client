module.exports = (app)->
  API =
    getUserModelFromUsername: (username)->
      if username is app.user.get('username') then return app.user

      userModel = app.users.findWhere({username: username})
      if userModel? then return userModel
      else console.warn "couldnt find the user from username: #{username}"

    getUsernameFromUserId: (id)->
      if id is app.user.id then return app.user.get 'username'

      userModel = app.users.byId(id)
      if userModel? then userModel.get('username')
      else console.warn "couldnt find the user from id: #{id}"

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
          app.request 'waitForData', callback, null, res
        .fail _.error
      else
        app.users.filtered.friends()

  app.users.queried = []

  isntAlreadyHere = (id)->
    if app.users.byId(id)? then false
    else true


  return reqresHandlers =
    'get:userModel:from:username': API.getUserModelFromUsername
    'get:username:from:userId': API.getUsernameFromUserId
    'get:userId:from:username': API.getUserIdFromUsername
    'get:profilePic:from:userId': API.getProfilePicFromUserId
    'users:search': API.searchUsers

