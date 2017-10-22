BrowserSelector = require './browser_selector'
ItemsList = require './items_list'

selectorTreeKeys =
  author: 'wdt:P50'
  genre: 'wdt:P136'
  subject: 'wdt:P921'
  owner: 'owner'
  # type
  # language

selectorsNames = Object.keys selectorTreeKeys

selectorsRegions = {}
for name in selectorsNames
  selectorsRegions["#{name}Region"] = "##{name}"

module.exports = Marionette.LayoutView.extend
  id: 'inventory-browser'
  template: require './templates/inventory_browser'
  regions: _.extend selectorsRegions, { itemsView: '#itemsView' }

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
    waitForOwnersModels = @getOwnersModels()

    waitForEntitiesSelectors = waitForInventoryData
      .then @ifViewIsIntact('showEntitySelectors')

    waitForOwnersSelector = waitForInventoryData
      # Same as grouping both promises but resolves only to the owners models
      .then -> waitForOwnersModels
      .then @ifViewIsIntact('showOwners')

    Promise.all [ waitForEntitiesSelectors, waitForOwnersSelector ]
    # Show the controls all at once
    .then @ifViewIsIntact('browserControlsReady')

  browserControlsReady: -> @ui.browserControls.addClass 'ready'

  getInventoryViewData: ->
    _.preq.get app.API.items.inventoryView
    .then @spreadData.bind(@)

  spreadData: (data)->
    _.log data, 'data'
    { @worksTree, @workUriItemsMap, itemsByDate } = data
    @showItemsListByIds itemsByDate

  showEntitySelectors: ->
    authors = Object.keys @worksTree['wdt:P50']
    genres = Object.keys @worksTree['wdt:P136']
    subjects = Object.keys @worksTree['wdt:P921']

    allUris = _.flatten [ authors, genres, subjects ]

    app.request 'get:entities:models', { uris: allUris, index: true }
    .then (entities)=>
      @showEntitySelector entities, 'wdt:P50', authors, 'author'
      @showEntitySelector entities, 'wdt:P136', genres, 'genre'
      @showEntitySelector entities, 'wdt:P921', subjects, 'subject'

  showItemsListByIds: (itemsIds)->
    app.request 'items:getByIds', itemsIds
    .then (models)=>
      collection = new Backbone.Collection models
      @itemsView.show new ItemsList { collection }

  showEntitySelector: (entities, property, propertyUris, name)->
    treeSection = @worksTree[property]
    models = _.values(_.pick(entities, propertyUris)).map addCount(treeSection)
    @showSelector name, models, treeSection

  getOwnersModels: ->
    Promise.all [
      getPublicOwnersModels()
      getFriendsModels()
      getGroupsModels()
      # Include the main user
      app.user
    ]
    .then _.flatten

  showOwners: (models)->
    # The tree section should map the section key (here owner ids) to work URIs
    treeSection = {}
    for ownerId, ownerWorksItemsMap of @worksTree.owner
      treeSection[ownerId] = Object.keys ownerWorksItemsMap

    @showSelector 'owner', models, treeSection

  showSelector: (name, models, treeSection)->
    # Using a filtered collection allows browser_selector to filter
    # options without re-rendering the whole view
    collection = new FilteredCollection(new SelectorCollection(models))
    @["#{name}Region"].show new BrowserSelector { name, collection, treeSection }

  filterSelect: (selectorView, selectedOption)->
    selectorName = selectorView.options.name
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

  filterSelectors: (intersectionWorkUris)->
    for selectorName in selectorsNames
      { currentView } = @["#{selectorName}Region"]
      currentView.filterOptions intersectionWorkUris

  displayFilteredItems: (intersectionWorkUris)->
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
      @_currentOwnerItemsByWork = @worksTree.owner[selectedOptionKey]
      return Object.keys @_currentOwnerItemsByWork
    else
      return @worksTree[selectorTreeKey][selectedOptionKey]

  resetFilterData: (selectorTreeKey)->
    if selectorTreeKey is 'owner' then @_currentOwnerItemsByWork = null

addCount = (urisData)-> (model)->
  uri = model.get 'uri'
  model.set 'count', urisData[uri].length
  return model

SelectorCollection = Backbone.Collection.extend
  comparator: (model)-> - model.get('count')

getPublicOwnersModels = ->
  nearby = new Backbone.Model
    icon: 'map-marker'
    label: _.I18n('nearby')
  nearby.matches = (filterRegex, rawInput)-> rawInput.length is 0
  return [ nearby ]

getFriendsModels = ->
  app.request 'fetch:friends'
  .then _.property('models')

getGroupsModels = -> app.groups.models
