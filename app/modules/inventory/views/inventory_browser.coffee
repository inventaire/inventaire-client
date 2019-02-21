BrowserSelector = require './browser_selector'
ItemsCascade = require './items_cascade'
ItemsTable = require './items_table'
SelectorsCollection = require '../collections/selectors'
FilterPreview = require './filter_preview'
getIntersectionWorkUris = require '../lib/browser/get_intersection_work_uris'
getUnknownModel = require '../lib/browser/get_unknown_model'

selectorsNames = [ 'author', 'genre', 'subject' ]
selectorsRegions = {}
selectorsNames.forEach (name)->
  selectorsRegions["#{name}Region"] = "##{name}"

module.exports = Marionette.LayoutView.extend
  id: 'inventory-browser'
  template: require './templates/inventory_browser'
  regions: _.extend selectorsRegions,
    filterPreview: '#filterPreview'
    itemsView: '#itemsView'

  behaviors:
    PreventDefault: {}

  initialize: ->
    @lazyRender = _.LazyRender @
    @filters = {}

    @display = localStorageProxy.getItem('inventory:display') or 'cascade'

  ui:
    browserControls: '#browserControls'
    displayControls: '#displayControls'

  events:
    'click #displayControls a': 'selectDisplay'
    'click #addToInventory': 'addToInventory'

  childEvents:
    'filter:select': 'onFilterSelect'

  serializeData: ->
    data = {}
    data[@display] = true
    return data

  onShow: ->
    @focusOnShow()

    waitForInventoryData = @getInventoryViewData()

    waitForEntitiesSelectors = waitForInventoryData
      .then @ifViewIsIntact('showEntitySelectors')

    waitForEntitiesSelectors
    # Show the controls all at once
    .then @ifViewIsIntact('browserControlsReady')

    @filterPreview.show new FilterPreview

  browserControlsReady: -> @ui.browserControls.addClass 'ready'

  getInventoryViewData: ->
    { user, group } = @options

    params = if user? then { user: user.id } else { group: group.id }

    _.preq.get app.API.items.inventoryView(params)
    .then @spreadData.bind(@)

  spreadData: (data)->
    { @worksTree, @workUriItemsMap, @itemsByDate } = data
    @showItemsListByIds()

  showEntitySelectors: ->
    authors = Object.keys @worksTree.author
    genres = Object.keys @worksTree.genre
    subjects = Object.keys @worksTree.subject

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
      @showEntitySelector entities, authors, 'author'
      @showEntitySelector entities, genres, 'genre'
      @showEntitySelector entities, subjects, 'subject'

  showItemsListByIds: (itemsIds)->
    # Default to showing the latest items
    itemsIds or= @itemsByDate
    allItemsIds = _.clone itemsIds
    collection = new Backbone.Collection []

    hasMore = -> itemsIds.length > 0
    fetchMore = ->
      batch = itemsIds.splice 0, 20
      if batch.length is 0 then return Promise.resolve()

      app.request 'items:getByIds', batch
      .then collection.add.bind(collection)

    @itemsViewParams = { collection, fetchMore, hasMore, allItemsIds }

    # Fetch a first batch before displaying
    # so that it doesn't start by displaying 'no item here'
    fetchMore()
    .then @showItemsByDisplayMode.bind(@)

  showItemsByDisplayMode: ->
    ItemsList = if @display is 'table' then ItemsTable else ItemsCascade
    @itemsView.show new ItemsList @itemsViewParams

  showEntitySelector: (entities, propertyUris, name)->
    treeSection = @worksTree[name]
    models = _.values(_.pick(entities, propertyUris)).map addCount(treeSection)
    @showSelector name, models, treeSection

  showSelector: (name, models, treeSection)->
    collection = getSelectorsCollection models
    @["#{name}Region"].show new BrowserSelector { name, collection, treeSection }

  onFilterSelect: (selectorView, selectedOption)->
    { selectorName } = selectorView
    _.type selectorName, 'string'
    selectedOptionKey = getSelectedOptionKey selectedOption, selectorName
    @filters[selectorName] = selectedOptionKey

    intersectionWorkUris = getIntersectionWorkUris @worksTree, @filters
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

    worksItems = _.pick @workUriItemsMap, intersectionWorkUris
    itemsIds = _.flatten _.values(worksItems)
    @showItemsListByIds itemsIds

  selectDisplay: (e)->
    display = e.currentTarget.id
    if display is @display then return
    @display = display
    localStorageProxy.setItem 'inventory:display', display
    @ui.displayControls.find('.selected').removeClass 'selected'
    $(e.currentTarget).addClass 'selected'
    @showItemsByDisplayMode()

  addToInventory: (e)->
    if _.isOpenedOutside e then return
    app.execute 'show:add:layout'

getSelectedOptionKey = (selectedOption, selectorName)->
  unless selectedOption? then return null
  return selectedOption.get 'uri'

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
