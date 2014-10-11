module.exports = class Search extends Backbone.Marionette.LayoutView
  id: 'searchLayout'
  template: require 'modules/search/layouts/templates/search'
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

  serializeData: ->
    search:
      nameBase: 'search'
      field: {}
      button:
        icon: 'search'
        classes: 'secondary postfix'

  onShow: ->
    app.execute 'search:field:maximize'
    app.execute 'show:loader', {region: @results1}

    if app.data?.ready? then @showAllLocalFilteredItems(@query)
    else app.vent.once 'data:ready', => @showAllLocalFilteredItems @query

    @searchEntities()

  searchEntities: ->
    # @resetResults([3,4])
    app.request 'search:entities', @query, @results3, @results4, '#searchField'
    .then ()=>
      # hide the loader if nothing is there to take its place
      if Items.personal.filtered.length is 0
        @results1.empty()

  showAllLocalFilteredItems: (query)->
    _.log query, 'showAllLocalFilteredItems query'
    @showLocalFilteredItems query, Items.personal.filtered, 'in your items', 1
    @showLocalFilteredItems query, Items.contacts.filtered, "in your contacts' items", 2

  onDestroy: -> app.execute 'search:field:unmaximize'

  showLocalFilteredItems: (query, collection, label, rank)->
    region = "results#{rank}"
    app.execute 'textFilter', collection, query
    if collection.length > 0
      @[region].show new app.View.ItemsList {collection: collection}
      @addHeader _.i18n(label), rank

  addHeader: (label, rank)->
    el = "header#{rank}"
    @ui[el].html "<h3 class='subheader'>#{label}</h3>"


  resetResults: (numbers)->
    numbers.forEach (num)->
      app.layout.entities.search["results#{num}"].empty()
      app.layout.entities.search["header#{num}"].empty()