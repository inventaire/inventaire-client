module.exports = (app)->

  app.users.queried = []

  searchByText = (text)->
    unless _.isNonEmptyString text
      return app.users.filtered.friends()

    app.users.data.remote.search text
    .then addUsersUnlessHere
    .then ->
      app.users.queried.push text
      return app.users.filtered.filterByText text

  searchByPosition = (bbox)->
    app.users.data.remote.searchByPosition bbox
    .then addUsersUnlessHere

  addUsersUnlessHere = (users)->
    # Need to waitForData as isntAlreadyHere can't
    # do it's job if user relations data haven't return yet
    app.request 'waitForData'
    .then ->
      for user in users
        addUserUnlessHere user

  addUserUnlessHere = (user)->
    if isntAlreadyHere user._id then app.users.public.add user

  isntAlreadyHere = (id)->
    if app.users.byId(id)? then return false
    if app.request 'user:isMainUser', id then return false
    return true

  return API =
    searchByText: searchByText
    searchByPosition: searchByPosition
