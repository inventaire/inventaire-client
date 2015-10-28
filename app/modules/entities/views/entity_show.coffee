EntityData = require './entity_data'
EntityActions = require './entity_actions'
wikiBarPlugin = require 'modules/general/plugins/wiki_bar'
ItemsList = require 'modules/inventory/views/items_list'

module.exports = Marionette.LayoutView.extend
  template: require './templates/entity_show'
  regions:
    entityData: '#entityData'
    entityActions: '#entityActions'
    localItems: '#localItems'
    publicItems: '#publicItems'

  serializeData: ->
    _.extend @model.toJSON(),
      back: backMessage()

  initialize: ->
    @initPlugins()
    @uri = @model.get('uri')
    fetchPublicItems @uri
    app.execute 'metadata:update:needed'

  initPlugins: ->
    wikiBarPlugin.call @

  onShow: ->
    @showEntityData()
    # need to wait to know if the user has an instance of this entity
    app.request('waitForUserData').then @showEntityActions.bind(@)
    @showLocalItems()  if app.user.loggedIn
    @showPublicItems()

    @model.updateMetadata()
    .finally app.execute.bind(app, 'metadata:update:done')

  events:
    'click a.showWikipediaPreview': 'toggleWikipediaPreview'
    'click #toggleWikiediaPreview': 'toggleWikiediaPreview'

  showEntityData: ->
    @entityData.show new EntityData
      model: @model
      entityPage: true

  showEntityActions: -> @entityActions.show new EntityActions {model: @model}

  # /!\ dispays public items!!
  # => should use an Items.network.filteredByEntity collection
  showLocalItems: -> showItems Items, @localItems, @uri
  # => should use an Items.nonNetwork.filteredByEntity collection
  showPublicItems: -> showItems Items.public, @publicItems, @uri

  toggleWikipediaPreview: -> @$el.trigger 'toggleWikiIframe', @

showItems = (baseCollection, region, uri)->
  # using the filtered collection to refresh on Collection 'add' events
  # uri can be found with filterByText as 'entity' is in item 'matches'.
  # baseCollection is thus expected to have a .filtered collection attached
  items = baseCollection.filtered.resetFilters().filterByText uri
  region.show new ItemsList
    collection: items

backMessage = ->
  if _.lastRouteMatch(/search\?/)
    return { message: _.i18n 'back to search results' }

fetchPublicItems = (uri)->
  app.request 'get:entity:public:items', uri
  .then spreadPublicData
  .catch _.Error('fetchPublicItems')

spreadPublicData = (data)->
  app.users.public.add data.users
  Items.public.add data.items