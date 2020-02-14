usersData = require '../users_data'

module.exports = (app)->

  app.users.queried = []

  # TODO: replace the local strict match filter and simply display
  # the last search result send by the server to integrate fuzzy match results
  searchByText = (text)->
    unless _.isNonEmptyString text
      return app.users.filtered.friends()

    usersData.search text
    .then addUsersUnlessHere
    .then ->
      app.users.queried.push text
      return app.users.filtered.filterByText text

  addUsersUnlessHere = (users)->
    # Need to waitForNetwork as isntAlreadyHere can't
    # do it's job if user relations data haven't return yet
    app.request 'waitForNetwork'
    .then -> app.execute 'users:add', users

  return { searchByText }
