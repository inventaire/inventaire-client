ItemsPreviewLists = require 'modules/inventory/views/items_preview_lists'

module.exports = Marionette.LayoutView.extend
  template: require './templates/edition_li'
  tagName: -> if @options.standalone then 'div' else 'li'
  className: -> if @options.standalone then 'editionLayout flex-row' else 'editionLi flex-row'

  regions:
    networkItemsRegion: '.networkItems'
    publicItemsRegion: '.publicItems'

  initialize: ->
    @uri = @model.get 'uri'
    @waitForPublicItems = fetchPublicItems @uri
    { @standalone } = @options

  onShow: ->
    @model.waitForWork
    .then @render.bind(@)

  onRender: ->
    @waitForPublicItems.then @showPublicItems.bind(@)

    if app.user.loggedIn
      app.request 'waitForItems'
      .then @showLocalItems.bind(@)

  serializeData: ->
    _.extend @model.toJSON(),
      standalone: @standalone
      work: if @standalone then @model.work?.toJSON()

  events:
    'click .add': 'add'

  add: -> app.execute 'show:item:creation:form', { entity: @model }

  showLocalItems: -> @showItemsPreviews 'network', @uri
  showPublicItems: -> @showItemsPreviews 'public', @uri
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

# Relies on the collection being already filled with all the items
# as the hereafter created collections won't update on 'add' events from baseCollections
# showItemsPreviews = (baseCollection, region, uri, header)->
  # itemsModels = baseCollection.byEntityUri uri
  # region.show new ItemsPreviewLists
  #   header: header
  #   itemsModels: itemsModels