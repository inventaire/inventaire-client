module.exports = class Search extends Backbone.Marionette.LayoutView
  id: 'searchLayout'
  template: require 'modules/search/layouts/templates/search'
  behaviors:
    AlertBox: {}
  serializeData: ->
    search:
      nameBase: 'search'
      field: {}
      button:
        icon: 'search'
        classes: 'secondary postfix'

  regions:
    results1: '#results1'
    results2: '#results2'
    results3: '#results3'
    results4: '#results4'
    results5: '#results5'

  ui:
    header1: '#header1'
    header2: '#header2'
    header3: '#header3'
    header4: '#header4'
    header5: '#header5'

  initialize: (params)->
    @query = params.query
    @listenTo Items.personal.filtered, 'add', @refreshItems
    @listenTo Items.friends.filtered, 'add', @refreshItems

  onShow: ->
    @updateSearchBar()
    app.request 'waitForData', @showItems, @
    @searchEntities()

  # ITEMS
  showItems: ->
    View = app.View.Items.List
    personalItems = [Items.personal.filtered, View, 'in your items', 1 ]
    friendsItems = [Items.friends.filtered, View, "in your friends' items", 2]

    @showCollection.apply @, personalItems
    @showCollection.apply @, friendsItems

  refreshItems: (e, collection)->
    @showItems @query


  # ENTITIES
  searchEntities: ->
    app.request 'search:entities', @query, @results3, @results4, @


  # UTILS
  showCollection: (collection, View, label, rank)->
    collection.filterByText @query
    if collection.length > 0
      view = new View {collection: collection}
      @showResult view, rank
      @addHeader _.i18n(label), rank

  addHeader: (label, rank)->
    el = "header#{rank}"
    @ui[el].html "<h3 class='subheader'>#{label}</h3>"

  showResult: (view, rank)->
    region = "results#{rank}"
    @[region].show view

  on404: -> app.execute 'show:404'
  onDestroy: -> app.execute 'search:field:unmaximize'

  updateSearchBar: ->
    $('#searchField').val @query
    app.execute 'search:field:maximize'