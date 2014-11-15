module.exports = (app)->
  users = new app.Collection.Users

  users.subCollections = [
    'public'
    'friends'
    'userRequests'
    'othersRequests'
  ]

  users.subCollections.forEach (status)->
    users[status] = new FilteredCollection(users)
    # shoud be subcollections only filter
    # to keep the subcollection relevant
    # DO NOT resetFilters() on those
    users[status].filterBy {status: status}
    # other filtering can happen on
    # the subcollection own filteredCollection
    users[status].filtered = new FilteredCollection(users[status])
    users[status].add = (userData)->
      # allows to be dispatched between users subcollections
      userData.status = status
      return users.add(userData)

  users.filtered = new FilteredCollection(users)

  # include main user in users to be able
  # to access it from get:username:from:userId
  users.add app.user

  return users