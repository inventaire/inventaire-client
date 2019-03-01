ItemsPreviewLists = require '../views/items_preview_lists'

# Sharing logic between work_layout and edition_layout
module.exports =
  initialize: ->
    { @standalone } = @options
    @waitForItems = @model.getItemsByCategories()
    @lazyShowItems = _.debounce showItemsPreviewLists.bind(@), 100

    _.extend @, entityItemsMethods

showItemsPreviewLists = ->
  @waitForItems
  .then =>
    # Happens when app/modules/entities/views/editions_list.coffee
    # are displayed within work_layout and thus re-redered on filter
    if @isDestroyed then return
    if app.user.loggedIn
      @showPersonalItems()
      @showNetworkItems()
    @showPublicItems()

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
