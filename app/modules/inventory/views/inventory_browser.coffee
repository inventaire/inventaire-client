BrowserSelector = require './browser_selector'

module.exports = Marionette.LayoutView.extend
  id: 'inventory-browser'
  template: require './templates/inventory_browser'
  regions:
    typeRegion: '#type'
    authorRegion: '#author'
    genreRegion: '#genre'
    subjectRegion: '#subject'
    languageRegion: '#language'
    ownerRegion: '#owner'
    transactionRegion: '#transaction'
    itemsView: '#itemsView'

  initialize: ->
    @lazyRender = _.LazyRender @

  ui:
    browserControls: '#browser-controls'

  onShow: ->
    @focusOnShow()

    Promise.all [
      @showEntitySelectors()
      @showOwners()
    ]
    # Show the controls all at once
    .then => @ui.browserControls.addClass 'ready'

  showEntitySelectors: ->
    _.preq.get app.API.items.inventoryView
    .then @spreadData.bind(@)

  spreadData: (data)->
    _.log data, 'data'

    types = Object.keys data['wdt:P31']
    authors = Object.keys data['wdt:P50']
    genres = Object.keys data['wdt:P136']

    allUris = _.flatten [ types, authors, genres ]

    app.request 'get:entities:models', { uris: allUris, index: true }
    .then (entities)=>
      @showEntitySelector data, entities, 'wdt:P31', types, 'type'
      @showEntitySelector data, entities, 'wdt:P50', authors, 'author'
      @showEntitySelector data, entities, 'wdt:P136', genres, 'genre'

  showEntitySelector: (data, entities, property, propertyUris, name)->
    models = _.values(_.pick(entities, propertyUris)).map addCount(data[property])
    @showSelector name, models

  showOwners: ->
    Promise.all [
      getPublicOwnersModels()
      getFriendsModels()
      getGroupsModels()
    ]
    .then _.flatten
    .then @showSelector.bind(@, 'owner')

  showSelector: (name, models)->
    # Using a filtered collection allows browser_selector to filter
    # options without re-rendering the whole view
    collection = new FilteredCollection(new SelectorCollection(models))
    @["#{name}Region"].show new BrowserSelector { name, collection }

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
