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
    itemsView: '#itemsView'

  initialize: ->
    @lazyRender = _.LazyRender @

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
      @showSelector data, entities, 'wdt:P31', types, 'type'
      @showSelector data, entities, 'wdt:P50', authors, 'author'
      @showSelector data, entities, 'wdt:P136', genres, 'genre'

  showSelector: (data, entities, property, propertyUris, name)->
    models = _.values(_.pick(entities, propertyUris)).map addCount(data[property])
    # Using a filtered collection allows browser_selector to filter
    # options without re-rendering the whole view
    collection = new FilteredCollection(new SelectorCollection(models))
    @["#{name}Region"].show new BrowserSelector { name, collection }

  onShow: ->
    @focusOnShow()

addCount = (urisData)-> (model)->
  uri = model.get 'uri'
  model.set 'count', urisData[uri].length
  return model

SelectorCollection = Backbone.Collection.extend
  comparator: (model)-> - model.get('count')
