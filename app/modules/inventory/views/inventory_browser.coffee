BrowserSelector = require './browser_selector'
BrowserOwnersSelector = require './browser_owners_selector'
ItemsList = require './items_list'
SelectorsCollection = require '../collections/selectors'
Filterable = require 'modules/general/models/filterable'
FilterPreview = require './filter_preview'

selectorTreeKeys =
  author: 'wdt:P50'
  genre: 'wdt:P136'
  subject: 'wdt:P921'
  owner: 'owner'
  # type
  # language

selectorsNames = Object.keys selectorTreeKeys

selectorsRegions = {}
selectorsNames.forEach (name)->
  selectorsRegions["#{name}Region"] = "##{name}"

module.exports = Marionette.LayoutView.extend
  id: 'inventory-browser'
  template: require './templates/inventory_browser'
  regions: _.extend selectorsRegions,
    filterPreview: '#filterPreview'
    itemsView: '#itemsView'

  initialize: ->
    @lazyRender = _.LazyRender @
    @filters = {}

  ui:
    browserControls: '#browser-controls'

  childEvents:
    'filter:select': 'filterSelect'

  onShow: ->
    @focusOnShow()

    waitForInventoryData = @getInventoryViewData()
    waitForOwnersCollections = @getOwnersModels()

    waitForEntitiesSelectors = waitForInventoryData
      .then @ifViewIsIntact('showEntitySelectors')

    waitForOwnersSelector = waitForInventoryData
      # Same as grouping both promises but resolves only to the owners models
      .then -> waitForOwnersCollections
      .then @ifViewIsIntact('showOwners')

    Promise.all [ waitForEntitiesSelectors, waitForOwnersSelector ]
    # Show the controls all at once
    .then @ifViewIsIntact('browserControlsReady')

    @filterPreview.show new FilterPreview

  browserControlsReady: -> @ui.browserControls.addClass 'ready'

  getInventoryViewData: ->
    _.preq.get app.API.items.inventoryView
    .then @spreadData.bind(@)

  spreadData: (data)->
    _.log data, 'data'
    { @worksTree, @workUriItemsMap, @itemsByDate } = data
    @showItemsListByIds()

  showEntitySelectors: ->
    authors = Object.keys @worksTree['wdt:P50']
    genres = Object.keys @worksTree['wdt:P136']
    subjects = Object.keys @worksTree['wdt:P921']

    allUris = _.flatten [ authors, genres, subjects ]
    # The 'unknown' attribute is used to list works that have no value
    # for one of those selector properties
    # Removing the 'unknown' URI is here required as 'get:entities:models'
    # won't know how to resolve it
    allUris = _.without allUris, 'unknown'

    app.request 'get:entities:models', { uris: allUris, index: true }
    .then (entities)=>
      # Re-adding the 'unknown' entity placeholder
      entities.unknown = getUnknownModel()
      @showEntitySelector entities, 'wdt:P50', authors, 'author'
      @showEntitySelector entities, 'wdt:P136', genres, 'genre'
      @showEntitySelector entities, 'wdt:P921', subjects, 'subject'

  showItemsListByIds: (itemsIds)->
    # Default to showing the latest items
    itemsIds or= @itemsByDate
    collection = new Backbone.Collection []

    more = -> itemsIds.length > 0
    fetchMore = ->
      batch = itemsIds.splice 0, 20
      if batch.length > 0
        app.request 'items:getByIds', batch
        .then collection.add.bind(collection)

    # Fetch a first batch before displaying
    # so that it doesn't start by displaying 'no item here'
    fetchMore()
    .then => @itemsView.show new ItemsList { collection, fetchMore, more }

  showEntitySelector: (entities, property, propertyUris, name)->
    treeSection = @worksTree[property]
    models = _.values(_.pick(entities, propertyUris)).map addCount(treeSection)
    @showSelector name, models, treeSection

  getOwnersModels: ->
    Promise.props
      highlighted: getSelectorsCollection [ app.user ]
      friends: getFriendsCollection()
      groups: getGroupsCollection()
      # nearby: getPublicOwnersCollection()

  showOwners: (collections)->
    # The tree section should map the section key (here owner ids) to work URIs
    treeSection = {}
    ownersWorksItemsMap = @worksTree.owner
    for ownerId, ownerWorksItemsMap of ownersWorksItemsMap
      treeSection[ownerId] = Object.keys ownerWorksItemsMap

    @ownerRegion.show new BrowserOwnersSelector {
      collections,
      treeSection,
      ownersWorksItemsMap
    }

  showSelector: (name, models, treeSection)->
    collection = getSelectorsCollection models
    @["#{name}Region"].show new BrowserSelector { name, collection, treeSection }

  filterSelect: (selectorView, selectedOption)->
    { selectorName } = selectorView
    _.type selectorName, 'string'
    selectorTreeKey = selectorTreeKeys[selectorName]
    if selectedOption?
      if selectorName is 'owner'
        selectedOptionKey = selectedOption.get '_id'
      else
        selectedOptionKey = selectedOption.get 'uri'

      @filters[selectorTreeKey] = selectedOptionKey
    else
      @filters[selectorTreeKey] = null

    intersectionWorkUris = @getIntersectionWorkUris()
    @filterSelectors intersectionWorkUris
    @displayFilteredItems intersectionWorkUris
    @filterPreview.currentView.updatePreview selectorName, selectedOption

  filterSelectors: (intersectionWorkUris)->
    for selectorName in selectorsNames
      { currentView } = @["#{selectorName}Region"]
      currentView.filterOptions intersectionWorkUris

  displayFilteredItems: (intersectionWorkUris)->
    unless intersectionWorkUris? then return @showItemsListByIds()

    if intersectionWorkUris.length is 0 then return @showItemsListByIds []

    if @_currentOwnerItemsByWork?
      worksItems = _.pick @_currentOwnerItemsByWork, intersectionWorkUris
    else
      worksItems = _.pick @workUriItemsMap, intersectionWorkUris
    itemsIds = _.flatten _.values(worksItems)
    @showItemsListByIds itemsIds

  getIntersectionWorkUris: ->
    subsets = []
    for selectorTreeKey, selectedOptionKey of @filters
      if selectedOptionKey?
        subsets.push @getFilterWorksUris(selectorTreeKey, selectedOptionKey)
      else
        @resetFilterData selectorTreeKey

    if subsets.length is 0 then return null

    intersectionWorkUris = _.intersection subsets...

    return _.log intersectionWorkUris, 'intersectionWorkUris'

  getFilterWorksUris: (selectorTreeKey, selectedOptionKey)->
    if selectorTreeKey is 'owner'
      @_currentOwnerItemsByWork = @worksTree.owner[selectedOptionKey] or {}
      return Object.keys @_currentOwnerItemsByWork
    else
      return @worksTree[selectorTreeKey][selectedOptionKey]

  resetFilterData: (selectorTreeKey)->
    if selectorTreeKey is 'owner' then @_currentOwnerItemsByWork = null

addCount = (urisData)-> (model)->
  uri = model.get 'uri'
  model.set 'count', urisData[uri].length
  return model

getFriendsCollection = ->
  app.request 'fetch:friends'
  .get 'models'
  .then getSelectorsCollection

getGroupsCollection = -> getSelectorsCollection app.groups.models

getSelectorsCollection = (models)->
  # Using a filtered collection allows browser_selector to filter
  # options without re-rendering the whole view
  new FilteredCollection(new SelectorsCollection(models))

unknownModel = null
getUnknownModel = ->
  # Creating the model only once requested
  # as _.i18n can't be called straight away at initialization
  unknownModel or= new Filterable
    uri: 'unknown'
    label: _.i18n('unknown')
    matchable: -> [ 'unknown', _.i18n('unknown') ]

  unknownModel.isUnknown = true

  return unknownModel
