error_ = require 'lib/error'

getAllEntityUris = (model)->
  # Make sure items are fetched for all sub entities as editions that aren't
  # shown (e.g. on work_layout, editions from other language than
  # the user are filtered-out by default) won't request their items
  # Then 'items:getByEntities' will take care of making every request only once.
  return model.fetchSubEntities()
  .then -> model.get 'allUris'

spreadItems = (uris)-> (items)->
  itemsByCategories =
    personal: []
    network: []
    public: []

  unless items?
    _.error error_.new('missing items collection', 500, { uris }), 'spreadItems'
    return itemsByCategories

  for item in items.models
    category = item.user.get 'itemsCategory'
    itemsByCategories[category].push item

  for category, categoryItems of itemsByCategories
    categoryItems.sort byDistance

  if app.user.has('position') and itemsByCategories.public.length > 0
    nearestPublicItem = itemsByCategories.public[0]
    nearestPublicItemDistance = getItemDistance nearestPublicItem
    nearbyKmPerimeter = getPerimeter nearestPublicItemDistance
    [ nearbyPublic, otherPublic ] = _.partition itemsByCategories.public, isNearby(nearbyKmPerimeter)
    itemsByCategories.nearbyPublic = nearbyPublic
    itemsByCategories.otherPublic = otherPublic

  return itemsByCategories

module.exports = ->
  if @itemsByCategory? then return Promise.resolve @itemsByCategory

  getAllEntityUris @
  .then (uris)->
    app.request 'items:getByEntities', uris
    .then spreadItems(uris)
  .tap (itemsByCategory)=> @itemsByCategory = itemsByCategory

byDistance = (itemA, itemB)-> getItemDistance(itemA) - getItemDistance(itemB)

isNearby = (nearbyKmPerimeter)-> (item)-> nearbyKmPerimeter > getItemDistance(item)

getItemDistance = (item)-> item.user?.kmDistanceFormMainUser or Infinity

getPerimeter = (nearestPublicItemDistance)->
  if nearestPublicItemDistance < 50 then Math.max (nearestPublicItemDistance * 2), 10
  else 100
