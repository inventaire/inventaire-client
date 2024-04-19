import FilteredCollection from 'backbone-filtered-collection'
import Users from './collections/users.ts'

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
  const fetcher = (category, initFilteredCollection?) => function () {
    if (fetched[category]) return waiters[category]

    fetched[category] = true
    waiters[category] = app.request('wait:for', 'relations')
      .then(() => app.request('get:users:models', app.relations[category]))
      .then(models => {
        users[category] = new Users(models)
        if (initFilteredCollection) {
          users[category].filtered = new FilteredCollection(users[category])
        }
      })

    return waiters[category]
  }

  app.reqres.setHandlers({
    'fetch:friends': fetcher('friends', true),
    'fetch:otherRequested': fetcher('otherRequested'),
  })

  return users
}
