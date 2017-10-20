BrowserSelector = require './browser_selector'

selectorTreeKeys =
  author: 'wdt:P50'
  genre: 'wdt:P136'
  subject: 'wdt:P921'
  # owner: null
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

    Promise.all [
      @showEntitySelectors()
      # @showOwners()
    ]
    # Show the controls all at once
    .then => @ui.browserControls.addClass 'ready'

  showEntitySelectors: ->
    _.preq.get app.API.items.inventoryView
    .then @spreadData.bind(@)

  spreadData: (data)->
    _.log data, 'data'
    { tree, workUriItemsMap } = data
    @tree = tree
    @workUriItemsMap = workUriItemsMap

    authors = Object.keys tree['wdt:P50']
    genres = Object.keys tree['wdt:P136']
    subjects = Object.keys tree['wdt:P921']

    allUris = _.flatten [ authors, genres, subjects ]

    app.request 'get:entities:models', { uris: allUris, index: true }
    .then (entities)=>
      @showEntitySelector tree, entities, 'wdt:P50', authors, 'author'
      @showEntitySelector tree, entities, 'wdt:P136', genres, 'genre'
      @showEntitySelector tree, entities, 'wdt:P921', subjects, 'subject'

  showEntitySelector: (tree, entities, property, propertyUris, name)->
    treeSection = tree[property]
    models = _.values(_.pick(entities, propertyUris)).map addCount(treeSection)
    @showSelector name, models, treeSection

  showOwners: ->
    Promise.all [
      getPublicOwnersModels()
      getFriendsModels()
      getGroupsModels()
    ]
    .then _.flatten
    .then @showSelector.bind(@, 'owner')

  showSelector: (name, models, treeSection)->
    # Using a filtered collection allows browser_selector to filter
    # options without re-rendering the whole view
    collection = new FilteredCollection(new SelectorCollection(models))
    @["#{name}Region"].show new BrowserSelector { name, collection, treeSection }

  filterSelect: (selectorView, selectedOption)->
    selectorName = selectorView.options.name
    selectorTreeKey = selectorTreeKeys[selectorName]
    if selectedOption?
      selectedOptionUri = selectedOption.get 'uri'
      @filters[selectorTreeKey] = selectedOptionUri
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
    # TODO: find and display corresponding items

  getIntersectionWorkUris: ->
    intersectionWorkUris = null
    for selectorTreeKey, selectedOption of @filters
      if selectedOption?
        filterWorkUris = @tree[selectorTreeKey][selectedOption]
        _.log filterWorkUris, "#{selectorTreeKey}:#{selectedOption} workUris"
        if intersectionWorkUris?
          intersectionWorkUris = _.intersection intersectionWorkUris, filterWorkUris
        else
          intersectionWorkUris = filterWorkUris

    return _.log intersectionWorkUris, 'intersectionWorkUris'

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
