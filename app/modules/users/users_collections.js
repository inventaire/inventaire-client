/* eslint-disable
    import/no-duplicates,
    no-return-assign,
    no-undef,
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
import Users from './collections/users'

export default function (app) {
  const users = new Users()

  users.filtered = new FilteredCollection(users)
  users.filtered.friends = function () {
    this.resetFilters()
    this.filterBy({ status: 'friends' })
    return users.filtered
  }

  const waiters = {}
  const fetched = {}
  const fetcher = (category, initFilteredCollection) => function () {
    if (fetched[category]) { return waiters[category] }

    fetched[category] = true
    waiters[category] = app.request('wait:for', 'relations')
      .then(() => app.request('get:users:models', app.relations[category]))
      .then(models => {
        users[category] = new Users(models)
        if (initFilteredCollection) {
          return users[category].filtered = new FilteredCollection(users[category])
        }
      })

    return waiters[category]
  }

  app.reqres.setHandlers({
    'fetch:friends': fetcher('friends', true),
    'fetch:otherRequested': fetcher('otherRequested')
  })

  return users
};
