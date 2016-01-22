Users = require './collections/users'

module.exports = (app)->
  users = new Users

  subCollections = [
    'public'
    'friends'
    'userRequested'
    'otherRequested'
    'nonRelationGroupUser'
  ]

  # /!\ do not replace by a for loop as the add functions would closure
  # on the same status variable,which will keep only the last value
  # the function scope here allow to have one status variable by collection
  subCollections.forEach (status)->
    users[status] = new FilteredCollection(users)
    # shoud be subcollections' only filter
    # to keep the subcollection relevant
    # DO NOT resetFilters() on those
    users[status].filterBy {status: status}
    # other filtering can happen on
    # the subcollection own filteredCollection
    users[status].filtered = new FilteredCollection(users[status])

    # allows to be dispatched between users subcollections
    setStatus = (userData)-> userData.status = status

    users[status].add = (data)->
      if _.isArray data then data.forEach setStatus
      else setStatus data

      return users.add data

  users.filtered = new FilteredCollection(users)
  users.filtered.friends = ->
    @resetFilters()
    @filterBy {status: 'friends'}

  keepMembersListUpdated users.friends
  keepMembersListUpdated users.public

  users.list = ->
    users.map _.property('id')
    .concat [app.user.id]

  return users

keepMembersListUpdated = (collection)->
  # init list
  collection.list = collection.map (member)-> member.id

  # keep list updated
  addMember = (model)-> collection.list.push model.id
  removeMember = (model)-> collection.list = _.without(collection.list, model.id)
  collection.on 'add', addMember
  collection.on 'remove', removeMember
