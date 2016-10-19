EntityData = require './entity_data'
EntityActions = require './entity_actions'
ItemsList = require 'modules/inventory/views/items_list'

module.exports = Marionette.LayoutView.extend
  template: require './templates/entity_show'
  regions:
    entityData: '#entityData'
    entityActions: '#entityActions'
    localItems: '#localItems'
    publicItems: '#publicItems'

  behaviors:
    WikiBar: {}

  serializeData: ->
    _.extend @model.toJSON(),
      back: backMessage()
      canRefreshData: true

  initialize: ->
    @uri = @model.get('uri')
    fetchPublicItems @uri
    app.execute 'metadata:update:needed'

  onShow: ->
    @showEntityData()
    # need to wait to know if the user has an instance of this entity
    app.request('wait:for', 'user').then @showEntityActions.bind(@)
    @showLocalItems()  if app.user.loggedIn
    @showPublicItems()

    @model.updateMetadata()
    .finally app.Execute('metadata:update:done')

  events:
    'click a.showWikipediaPreview': 'toggleWikipediaPreview'
    'click #toggleWikiediaPreview': 'toggleWikiediaPreview'
    'click .refreshData': 'refreshData'

  showEntityData: ->
    @entityData.show new EntityData
      model: @model
      entityPage: true

  showEntityActions: -> @entityActions.show new EntityActions {model: @model}

  showLocalItems: -> showItems app.items.network, @localItems, @uri
  showPublicItems: -> showItems app.items.public, @publicItems, @uri

  toggleWikipediaPreview: -> @$el.trigger 'toggleWikiIframe', @

  refreshData: -> app.execute 'show:entity:refresh', @model

showItems = (baseCollection, region, uri)->
  # using the filtered collection to refresh on Collection 'add' events
  # uri can be found with filterByText as 'entity' is in item 'matches'.
  # baseCollection is thus expected to have a .filtered collection attached
  items = baseCollection.filtered.resetFilters().filteredByEntityUri uri
  region.show new ItemsList
    collection: items

backMessage = ->
  if _.lastRouteMatch(/search\?/)
    return { message: _.i18n 'back to search results' }

fetchPublicItems = (uri)->
  app.request 'get:entity:public:items', uri
  .then _.Log('public items')
  .then spreadPublicData
  .catch _.Error('fetchPublicItems')

spreadPublicData = (data)->
  app.execute 'users:public:add', data.users
  app.items.public.add data.items