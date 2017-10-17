getAllEntityItems = (model)->
  mainUri = model.get 'uri'
  if model.hasSubentities
    # Make sure items are fetched for all sub entities as editions that aren't
    # shown (e.g. on work_layout, editions from other language than
    # the user are filtered-out by default) won't request their items
    # Then 'items:getByEntities' will take care of making every request only once.

    # Redefining model.waitForSubentities so that promises depending on it
    # (cf onRender) wait for the items to return before rendering
    # (as the collection won't keep in sync with items arriving late)
    return model.waitForSubentities
    .then -> app.request 'items:getByEntities', model.get('allUris')
    .catch _.Error("#{mainUri} subentities fetchPublicItems err")

  else
    return app.request 'items:getByEntities', [ mainUri ]

spreadItems = (items)->
  itemsByCategories =
    personal: []
    network: []
    public: []

  for item in items.models
    category = item.user.get 'itemsCategory'
    itemsByCategories[category].push item

  return itemsByCategories

module.exports = ->
  if @itemsByCategory? then return Promise.resolve @itemsByCategory

  getAllEntityItems @
  .then spreadItems
  .tap (itemsByCategory)=> @itemsByCategory = itemsByCategory
