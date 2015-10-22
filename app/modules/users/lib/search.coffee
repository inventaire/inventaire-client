module.exports = (app)->
  searchUsers = (text)->
    unless text? and text isnt ''
      return app.users.filtered.friends()

    app.users.data.remote.search(text)
    .then (res)->
      # Need to waitForData as isntAlreadyHere can't
      # do it's job if user relations data haven't return yet
      app.request('waitForData')
      .then addSearchedUsers.bind(null, text, res)

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

  return searchUsers
