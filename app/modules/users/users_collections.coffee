Users = require './collections/users'

module.exports = (app)->
  users = new Users

  users.subCollections = [
    'public'
    'friends'
    'userRequested'
    'otherRequested'
    'nonRelationGroupUser'
  ]

  users.subCollections.forEach (status)->
    users[status] = new FilteredCollection(users)
    # shoud be subcollections' only filter
    # to keep the subcollection relevant
    # DO NOT resetFilters() on those
    users[status].filterBy {status: status}
    # other filtering can happen on
    # the subcollection own filteredCollection
    users[status].filtered = new FilteredCollection(users[status])
    users[status].add = (data)->
      # allows to be dispatched between users subcollections
      if _.isArray(data)
        data.forEach (userData)-> userData.status = status
      else data.status = status
      return users.add(data)

  users.subCollectionsStats = ->
    result = []
    result.push 'users', @length
    @subCollections.forEach (status)=>
      result.push status, @[status].length
    return result

  users.filtered = new FilteredCollection(users)
  users.filtered.friends = ->
    @resetFilters()
    @filterBy {status: 'friends'}

  keepMembersListUpdated users.friends
  keepMembersListUpdated users.public

  return users

keepMembersListUpdated = (collection)->
  updater = lazyMembersListUpdater(collection)
  collection.on 'add', updater
  collection.on 'remove', updater
  updater()

updateMembersList = (collection)->
  collection.list = collection.map (member)-> member.id

lazyMembersListUpdater = (collection)->
  _.debounce(updateMembersList.bind(null, collection), 200)