module.exports = (app)->
  API =
    getUsernameFromUserId: (id)->
        userModel = app.users.byId(id)
        if userModel? then userModel.get('username')
        else console.warn "couldnt find the user from id: #{id}"

    getUserIdFromUsername: (username)->
        userModel = app.users.findWhere({username: username})
        if userModel? then userModel.id
        else console.warn "couldnt find the user from username: #{username}"

    getProfilePicFromUserId: (id)->
        userModel = app.users.byId(id)
        if userModel? then userModel.get 'picture'
        else console.warn "couldnt find the user from id: #{id}"

    searchUsers: (text)->
      app.users.data.remote.search(text)
      .then (res)->
        _.log res, 'searchUsers res'
        res.forEach (contact)->
          app.users.public.add(contact) if isntAlreadyHere(contact._id)
        app.users.queried.push(text)
        return app.users.public.filtered
      .fail _.error

  app.users.queried = []

  isntAlreadyHere = (id)->
    if app.users.byId(id)? then false
    else true


  return reqresHandlers =
    'get:username:from:userId': API.getUsernameFromUserId
    'get:userId:from:username': API.getUserIdFromUsername
    'get:profilePic:from:userId': API.getProfilePicFromUserId
    'users:search': API.searchUsers

