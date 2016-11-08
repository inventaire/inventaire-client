ItemsPreviewLists = require '../views/items_preview_lists'

# Sharing logic between work_layout and edition_layout
module.exports =
  initialize: ->
    { @standalone } = @options
    fetchAllPublicItems @model
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

fetchAllPublicItems = (model)->
  uri = model.get 'uri'
  @waitForPublicItems = fetchPublicItems uri
  if model.hasSubentities
    # Make sure public items are fetched for all sub entities as editions that aren't
    # shown (e.g. on work_layout, editions from other language than the user are
    # filtered-out by default) won't trigger a fetchPublicItems call
    # Then fetchPublicItems will take care of making every request only once
    # Redefining model.waitForSubentities so that promises depending on it (cf onRender)
    # wait for the public items to return before rendering (as the collection won't
    # keep in sync with items arriving late)
    model.waitForSubentities = model.waitForSubentities
      .then -> Promise.all model.get('subEntitiesUris').map(fetchPublicItems)
      .catch _.Error("#{uri} subentities fetchPublicItems err")

entityItemsMethods =
  # TODO: replace showNetworkItems by showFriendsAndGroups,
  # moving non-confirmed friends to public items
  showNetworkItems: -> @showItemsPreviews 'network'
  showPublicItems: -> @showItemsPreviews 'public'
  # Relies on the collection being already filled with all the items as the hereafter
  # created collections won't update on 'add' events from baseCollections
  showItemsPreviews: (category)->
    allUris = @model.get 'allUris'
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
  .then _.Log("#{uri} public items")
  .then spreadPublicData
  .catch _.Error('fetchPublicItems')

# Adding the users and items to the global collections
spreadPublicData = (data)->
  app.execute 'users:public:add', data.users
  app.items.public.add data.items
