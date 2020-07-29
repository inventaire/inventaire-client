ItemsPreviewLists = require '../views/items_preview_lists'

# Sharing logic between work_layout and edition_layout
module.exports =
  initialize: ->
    @waitForItems = @model.getItemsByCategories()
    @lazyShowItems = _.debounce showItemsPreviewLists.bind(@), 100

showItemsPreviewLists = ->
  @waitForItems
  .then (itemsByCategory)=>
    # Happens when app/modules/entities/views/editions_list.coffee
    # are displayed within work_layout and thus re-redered on filter
    if @isDestroyed then return
    if app.user.loggedIn
      showItemsPreviews.call @, itemsByCategory, 'personal'
      # TODO: replace network by only friends and groups,
      # moving non-confirmed friends to public items
      showItemsPreviews.call @, itemsByCategory, 'network'
    if app.user.has 'position'
      showItemsPreviews.call @, itemsByCategory, 'nearbyPublic'
      showItemsPreviews.call @, itemsByCategory, 'otherPublic'
    else
      showItemsPreviews.call @, itemsByCategory, 'public'

    @$el.find('.items-lists-loader').hide()

showItemsPreviews = (itemsByCategory, category)->
  itemsModels = itemsByCategory[category]
  compact = not @options.standalone
  @["#{category}ItemsRegion"].show new ItemsPreviewLists {
    category,
    itemsModels,
    compact,
    @displayItemsCovers
  }
