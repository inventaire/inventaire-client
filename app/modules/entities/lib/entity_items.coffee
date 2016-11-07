ItemsPreviewLists = require '../views/items_preview_lists'

# Sharing logic between work_layout and edition_li
module.exports =
  initialize: ->
    @uri = @model.get 'uri'
    @waitForPublicItems = fetchPublicItems @uri
    { @standalone } = @options
    _.extend @, entityItemsMethods

  onRender: ->
    @waitForPublicItems.then @showPublicItems.bind(@)

    if app.user.loggedIn
      app.request 'waitForItems'
      .then @showLocalItems.bind(@)

entityItemsMethods =
  showLocalItems: -> @showItemsPreviews 'network', @uri
  showPublicItems: -> @showItemsPreviews 'public', @uri
  # Relies on the collection being already filled with all the items as the hereafter
  # created collections won't update on 'add' events from baseCollections
  showItemsPreviews: (category, uri)->
    itemsModels = app.items[category].byEntityUri uri
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

spreadPublicData = (data)->
  app.execute 'users:public:add', data.users
  app.items.public.add data.items
