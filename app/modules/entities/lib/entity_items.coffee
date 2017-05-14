ItemsPreviewLists = require '../views/items_preview_lists'

# Sharing logic between work_layout and edition_layout
module.exports =
  initialize: ->
    { @standalone } = @options
    @waitForItems = getAllEntityItems(@model)
      .then spreadItems.bind(@)
    _.extend @, entityItemsMethods

  onRender: ->
    @waitForItems
    .then =>
      # Happens when app/modules/entities/views/editions_list.coffee
      # are displayed within work_layout and thus re-redered on filter
      if @isDestroyed then return
      if app.user.loggedIn
        @showPersonalItems()
        @showNetworkItems()
      @showPublicItems()

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
  itemsByCategory =
    personal: []
    network: []
    public: []

  for item in items.models
    category = item.user.get 'itemsCategory'
    itemsByCategory[category].push item

  return itemsByCategory

entityItemsMethods =
  showPersonalItems: -> @showItemsPreviews 'personal'
  # TODO: replace showNetworkItems by showFriendsAndGroups,
  # moving non-confirmed friends to public items
  showNetworkItems: -> @showItemsPreviews 'network'
  showPublicItems: -> @showItemsPreviews 'public'
  # Relies on the collection being already filled with all the items as the hereafter
  # created collections won't update on 'add' events from baseCollections
  showItemsPreviews: (category)->
    @waitForItems
    .then (itemsByCategory)=>
      itemsModels = itemsByCategory[category]
      if itemsModels.length is 0 then return

      @["#{category}ItemsRegion"].show new ItemsPreviewLists {
        category,
        itemsModels
      }
