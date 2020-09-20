BrowserSelector = require './browser_selector'
ItemsCascade = require './items_cascade'
ItemsTable = require './items_table'
SelectorsCollection = require '../collections/selectors'
FilterPreview = require './filter_preview'
getIntersectionWorkUris = require '../lib/browser/get_intersection_work_uris'
getUnknownModel = require '../lib/browser/get_unknown_model'
error_ = require 'lib/error'
{ startLoading, stopLoading } = require 'modules/general/plugins/behaviors'

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
    Loading: {}

  initialize: ->
    @filters = {}

    @display = localStorageProxy.getItem('inventory:display') or 'cascade'
    @isMainUser = @options.isMainUser
    @groupContext = @options.group?

  ui:
    browserControls: '#browserControls'
    currentDisplayOption: '#displayControls .current div'

  events:
    'click #displayOptions a': 'selectDisplay'

  childEvents:
    'filter:select': 'onFilterSelect'

  serializeData: ->
    data = {}
    data[@display] = true
    data.displayMode = @display
    data.isMainUser = @isMainUser
    return data

  onShow: -> @initBrowser()

  initBrowser: ->
    startLoading.call @, { selector: '#browserFilters', timeout: 180 }
    { itemsDataPromise } = @options
    waitForInventoryData = itemsDataPromise
      .then @ifViewIsIntact('spreadData')
      .then @ifViewIsIntact('showItemsListByIds', null)

    waitForEntitiesSelectors = waitForInventoryData
      .then @ifViewIsIntact('showEntitySelectors')

    waitForEntitiesSelectors
    # Show the controls all at once
    .then @ifViewIsIntact('browserControlsReady')

    @filterPreview.show new FilterPreview

  browserControlsReady: ->
    @ui.browserControls.addClass 'ready'
    stopLoading.call @, '#browserFilters'

  spreadData: (data)->
    { @worksTree, @workUriItemsMap, @itemsByDate } = data

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
    .then @ifViewIsIntact('_showEntitySelectors', authors, genres, subjects)

  _showEntitySelectors: (authors, genres, subjects, entities)->
    # Re-adding the 'unknown' entity placeholder
    entities.unknown = getUnknownModel()
    @showEntitySelector entities, authors, 'author'
    @showEntitySelector entities, genres, 'genre'
    @showEntitySelector entities, subjects, 'subject'

  showItemsListByIds: (itemsIds)->
    # Default to showing the latest items
    itemsIds or= @itemsByDate
    # - Deduplicate as editions with several P629 values might have generated duplicates
    # - Clone to avoid modifying @itemsByDate
    itemsIds = _.uniq itemsIds
    collection = new Backbone.Collection []

    remainingItems = _.clone itemsIds
    hasMore = -> remainingItems.length > 0
    fetchMore = ->
      batch = remainingItems.splice 0, 20
      if batch.length is 0 then return Promise.resolve()

      app.request 'items:getByIds', batch
      .then collection.add.bind(collection)

    @itemsViewParams = {
      collection,
      fetchMore,
      hasMore,
      itemsIds,
      @isMainUser,
      @groupContext,
      # Regenerate the whole view to re-request the data without the deleted items
      afterItemsDelete: @initBrowser.bind(@)
    }

    # Fetch a first batch before displaying
    # so that it doesn't start by displaying 'no item here'
    fetchMore()
    .then @showItemsByDisplayMode.bind(@)

  showItemsByDisplayMode: ->
    ItemsList = if @display is 'table' then ItemsTable else ItemsCascade
    @_lastShownDisplay = @display
    @itemsView.show new ItemsList @itemsViewParams

  showEntitySelector: (entities, propertyUris, name)->
    treeSection = @worksTree[name]
    models = _.values(_.pick(entities, propertyUris)).map addCount(treeSection, name)
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
    @ui.currentDisplayOption.toggleClass('shown')

    # If @_lastShownDisplay isn't defined, the inventory data probably didn't arrive yet
    # and the items were not shown yet
    if @_lastShownDisplay? and @_lastShownDisplay isnt display
      @showItemsByDisplayMode()

getSelectedOptionKey = (selectedOption, selectorName)->
  unless selectedOption? then return null
  return selectedOption.get 'uri'

addCount = (urisData, name)-> (model)->
  uri = model.get 'uri'
  uris = urisData[uri]
  if uris?
    model.set 'count', uris.length
  else
    # Known case: a Wikidata redirection that wasn't properly propagated
    error_.report 'missing section data', { name, uri }
    model.set 'count', 0
  return model

getSelectorsCollection = (models)->
  # Using a filtered collection allows browser_selector to filter
  # options without re-rendering the whole view
  new FilteredCollection(new SelectorsCollection(models))
