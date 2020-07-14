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

  return itemsByCategories

module.exports = ->
  if @itemsByCategory? then return Promise.resolve @itemsByCategory

  getAllEntityUris @
  .then (uris)->
    app.request 'items:getByEntities', uris
    .then spreadItems(uris)
  .tap (itemsByCategory)=> @itemsByCategory = itemsByCategory

byDistance = (itemA, itemB)->
  a = itemA.user?.kmDistanceFormMainUser or Infinity
  b = itemB.user?.kmDistanceFormMainUser or Infinity
  return a - b
