import usersData from '../users_data'

export default function (app) {
  app.users.queried = []

  // TODO: replace the local strict match filter and simply display
  // the last search result send by the server to integrate fuzzy match results
  const searchByText = function (text) {
    if (!_.isNonEmptyString(text)) {
      return app.users.filtered.friends()
    }

    return usersData.search(text)
    .then(addUsersUnlessHere)
    .then(() => {
      app.users.queried.push(text)
      return app.users.filtered.filterByText(text)
    })
  }

  const addUsersUnlessHere = users => {
    // Need to waitForNetwork as isntAlreadyHere can't
    // do it's job if user relations data haven't return yet
    return app.request('waitForNetwork')
    .then(() => app.execute('users:add', users))
  }

  return { searchByText }
}
