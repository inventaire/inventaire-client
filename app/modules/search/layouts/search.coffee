module.exports = class Search extends Backbone.Marionette.LayoutView
  id: 'searchLayout'
  template: require 'modules/search/layouts/templates/search'
  behaviors:
    AlertBox: {}

  regions:
    results1: '#results1'
    results2: '#results2'
    results3: '#results3'
    results4: '#results4'

  ui:
    header1: '#header1'
    header2: '#header2'
    header3: '#header3'
    header4: '#header4'

  initialize: (params)->
    @query = params.query
    @listenTo Items.personal.filtered, 'add', @refreshAllLocalFilteredItems
    @listenTo Items.contacts.filtered, 'add', @refreshAllLocalFilteredItems

  serializeData: ->
    search:
      nameBase: 'search'
      field: {}
      button:
        icon: 'search'
        classes: 'secondary postfix'

  onShow: ->
    $('#searchField').val @query
    app.execute 'search:field:maximize'
    # app.execute 'show:loader', {region: @results1}

    app.request 'waitForData', @showAllLocalFilteredItems, @, @query

    @searchEntities()

  showAllLocalFilteredItems: (query)->
    query ||= @query
    _.log query, 'showAllLocalFilteredItems query'
    @showLocalFilteredItems query, Items.personal.filtered, 'in your items', 1
    @showLocalFilteredItems query, Items.contacts.filtered, "in your contacts' items", 2

  showLocalFilteredItems: (query, collection, label, rank)->
    region = "results#{rank}"
    app.execute 'textFilter', collection, query
    if collection.length > 0
      @[region].show new app.View.ItemsList {collection: collection}
      @addHeader _.i18n(label), rank

  refreshAllLocalFilteredItems: (e, collection)->
    @showAllLocalFilteredItems(@query)

  searchEntities: ->
    app.request 'search:entities', @query, @results3, @results4, @

  on404: -> app.execute 'show:404'

  addHeader: (label, rank)->
    el = "header#{rank}"
    @ui[el].html "<h3 class='subheader'>#{label}</h3>"


  resetResults: (numbers = [1..4])->
    numbers.forEach (num)=>
      @["results#{num}"]?.empty?()
      @["header#{num}"]?.empty?()

  onDestroy: -> app.execute 'search:field:unmaximize'