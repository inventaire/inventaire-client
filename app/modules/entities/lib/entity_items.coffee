ItemsPreviewLists = require '../views/items_preview_lists'

# Sharing logic between work_layout and edition_layout
module.exports =
  initialize: ->
    @waitForItems = @model.getItemsByCategories()
    @lazyShowItems = _.debounce showItemsPreviewLists.bind(@), 100

showItemsPreviewLists = ->
  @waitForItems
  .then =>
    # Happens when app/modules/entities/views/editions_list.coffee
    # are displayed within work_layout and thus re-redered on filter
    if @isDestroyed then return
    if app.user.loggedIn
      showItemsPreviews.call @, 'personal'
      # TODO: replace network by only friends and groups,
      # moving non-confirmed friends to public items
      showItemsPreviews.call @, 'network'
    showItemsPreviews.call @, 'public'

showItemsPreviews = (category)->
  @waitForItems
  .then (itemsByCategory)=>
    itemsModels = itemsByCategory[category]
    if itemsModels.length is 0 then return

    @["#{category}ItemsRegion"].show new ItemsPreviewLists {
      category,
      itemsModels
    }
