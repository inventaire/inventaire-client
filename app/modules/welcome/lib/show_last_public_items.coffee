Items = require 'modules/inventory/collections/items'
ItemsList = require 'modules/inventory/views/items_list'
addUsersAndItems = require 'modules/inventory/lib/add_users_and_items'
{ lastPublicItems } = app.API.items

module.exports = (params)->
  { region, allowMore, limit, assertImage } = params
  collection = new Items

  # Use an object to store the flag so that it can be modified
  # by functions the object is passed to
  moreData = { status: true }
  more = -> moreData.status
  fetchMore = FetchMore collection, moreData, limit, assertImage

  fetchMore()
  .then ->
    region.show new ItemsList
      collection: collection
      # if not allowMore, let ItemsList set the default values
      fetchMore: if allowMore then fetchMore
      more: if allowMore then more
      showDistance: true

FetchMore = (collection, moreData, limit, assertImage)->
  # Avoiding fetching more items several times at a time
  # as it will just return the same items, given that it will pass
  # the same arguments.
  # Known case: when the view is locked on the infiniteScroll trigger
  busy = false
  fetchMore = ->
    if busy then return _.preq.resolved

    busy = true
    offset = collection.length
    _.preq.get lastPublicItems(limit, offset, assertImage)
    .then addUsersAndItems.bind(null, collection)
    .catch catch404
    .finally -> busy = false

  catch404 = (err)->
    if err.status is 404
      moreData.status = false
      _.warn 'no more public items to show'
    else
      throw err

  return fetchMore
