ItemsPreviewLists = require '../views/items_preview_lists'

# Sharing logic between work_layout and edition_li
module.exports =
  initialize: ->
    @waitForPublicItems = fetchPublicItems @model.get('uri')
    { @standalone } = @options
    _.extend @, entityItemsMethods

  onRender: ->
    # Always showing public items
    Promise.all [
      @waitForPublicItems
      @model.waitForSubentities
    ]
    .then @showPublicItems.bind(@)

    # Showing network items only if logged in
    if app.user.loggedIn
      Promise.all [
        app.request 'waitForItems'
        @model.waitForSubentities
      ]
      .then @showNetworkItems.bind(@)

entityItemsMethods =
  showNetworkItems: -> @showItemsPreviews 'network'
  showPublicItems: -> @showItemsPreviews 'public'
  # Relies on the collection being already filled with all the items as the hereafter
  # created collections won't update on 'add' events from baseCollections
  showItemsPreviews: (category)->
    allUris = @model.get 'allUris'
    _.log allUris, "allUris #{@model.get('uri')}"
    itemsModels = app.items[category].byEntityUris allUris
    if itemsModels.length is 0 then return

    @["#{category}ItemsRegion"].show new ItemsPreviewLists
      category: category
      itemsModels: itemsModels

alreadyFetched = []
fetchPublicItems = (uri)->
  if uri in alreadyFetched then return _.preq.resolved

  alreadyFetched.push uri

  app.request 'get:entity:public:items', uri
  .then _.Log('public items')
  .then spreadPublicData
  .catch _.Error('fetchPublicItems')

# Adding the users and items to the global collections
spreadPublicData = (data)->
  app.execute 'users:public:add', data.users
  app.items.public.add data.items
