itemsFiltered = require './items_filtered'

module.exports =
  initialize: (app)->

    Items.filtered = itemsFiltered Items

    Items.personal.filtered = itemsFiltered Items.personal
    Items.friends.filtered = itemsFiltered Items.friends
    Items.public.filtered = itemsFiltered Items.public
    Items.network.filtered = itemsFiltered Items.network

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
    .then Items.filtered.refilter.bind(Items.filtered)

filterInventory = (filterName, filterFn)->
  unless singleFilterReady filterName
    Items.filtered.resetFilters()
    Items.filtered.filterBy filterName, filterFn

filterInventoryByOwner = (owner)->
  filterInventory "owner:#{owner}", (itemModel)-> itemModel.get('owner') is owner

ownedByFriendOrMainUser = (itemModel)->
  ownerId = itemModel.get 'owner'
  if app.request 'user:isMainUser', ownerId then return true
  else if app.request 'user:isFriend', ownerId then return true
  else false

filterInventoryByFriendsAndMainUser = filterInventory.bind null, 'friendsAndMainUser', ownedByFriendOrMainUser

filterInventoryByGroup = (groupModel)->
  Items.filtered.resetFilters()
  allMembers = groupModel.allMembers()
  mainUserId = app.user.id
  Items.filtered.filterBy 'group', (itemModel)->
    owner = itemModel.get 'owner'
    unless owner in allMembers then return false

    if owner is mainUserId then isntPrivateItem itemModel
    else true

isntPrivateItem = (itemModel)->
  itemModel.get('listing') isnt 'private'

filterItemsByText = (text, reset)->
  Items.filtered.filterByText text, reset

includeTransaction = (transaction)->
  Items.filtered.removeFilter "exclude:#{transaction}"

excludeTransaction = (transaction)->
  Items.filtered.filterBy "exclude:#{transaction}", (item)->
    item.get('transaction') isnt transaction

singleFilterReady = (filter)->
  filters = Items.filtered.getFilters()
  return filters.length is 1 and filters[0] is filter
