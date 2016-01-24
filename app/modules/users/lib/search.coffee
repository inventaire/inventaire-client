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
    .then -> app.execute 'users:public:add', users

  return API =
    searchByText: searchByText
    searchByPosition: searchByPosition
