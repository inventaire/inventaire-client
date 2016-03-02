itemsFiltered = require './items_filtered'

module.exports = (app)->
  { items } = app

  items.filtered = itemsFiltered items
  items.personal.filtered = itemsFiltered items.personal
  items.friends.filtered = itemsFiltered items.friends
  items.public.filtered = itemsFiltered items.public
  items.network.filtered = itemsFiltered items.network

  filterInventory = (filterName, filterFn)->
    unless singleFilterReady filterName
      items.filtered.resetFilters()
      items.filtered.filterBy filterName, filterFn

  filterInventoryByOwner = (owner)->
    filterInventory "owner:#{owner}", (itemModel)-> itemModel.get('owner') is owner

  ownedByFriendOrMainUser = (itemModel)->
    ownerId = itemModel.get 'owner'
    if app.request 'user:isMainUser', ownerId then return true
    else if app.request 'user:isFriend', ownerId then return true
    else false

  filterInventoryByFriendsAndMainUser = filterInventory.bind null, 'friendsAndMainUser', ownedByFriendOrMainUser

  filterInventoryByGroup = (groupModel)->
    items.filtered.resetFilters()
    allMembersIds = groupModel.allMembersIds()
    mainUserId = app.user.id
    items.filtered.filterBy 'group', (itemModel)->
      owner = itemModel.get 'owner'
      unless owner in allMembersIds then return false

      if owner is mainUserId then isntPrivateItem itemModel
      else true

  isntPrivateItem = (itemModel)->
    itemModel.get('listing') isnt 'private'

  filterItemsByText = (text, reset)->
    items.filtered.filterByText text, reset

  includeTransaction = (transaction)->
    items.filtered.removeFilter "exclude:#{transaction}"

  excludeTransaction = (transaction)->
    items.filtered.filterBy "exclude:#{transaction}", (item)->
      item.get('transaction') isnt transaction

  singleFilterReady = (filter)->
    filters = items.filtered.getFilters()
    return filters.length is 1 and filters[0] is filter

  app.commands.setHandlers
    'filter:inventory:owner': filterInventoryByOwner
    'filter:inventory:friends:and:main:user': filterInventoryByFriendsAndMainUser
    'filter:inventory:group': filterInventoryByGroup
    'filter:items:byText': filterItemsByText
    'filter:inventory:transaction:include': includeTransaction
    'filter:inventory:transaction:exclude': excludeTransaction

  app.request 'waitForFriendsItems'
  # wait for debounced recalculations
  # ex: user:isFriend depends on app.users.friends.list
  .delay(400)
  .then items.filtered.refilter.bind(items.filtered)
