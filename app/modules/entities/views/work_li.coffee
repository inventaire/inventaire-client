module.exports = Marionette.ItemView.extend
  template: require './templates/work_li'
  className: ->
    prefix = @model.get 'prefix'
    "workLi entity-prefix-#{prefix}"

  attributes: ->
    # Used by deduplicate_layout
    'data-uri': @model.get('uri')

  initialize: ->
    @lazyRender = _.LazyRender @
    @listenTo @model, 'change', @lazyRender
    app.execute 'uriLabel:update'

    { @showAllLabels, @showActions } = @options
    @showActions ?= true

    if @showActions
      # Required by @getNetworkItemsCount
      @model.getItemsByCategories()
      .then @lazyRender

  behaviors:
    PreventDefault: {}

  ui:
    zoomButtons: '.zoom-button .buttons span'
    cover: 'img'

  events:
    'click a.addToInventory': 'showItemCreationForm'
    'click a.zoom-button': 'toggleZoom'

  showItemCreationForm: (e)->
    unless _.isOpenedOutside(e)
      app.execute 'show:item:creation:form', { entity: @model }

  serializeData: ->
    attrs = _.extend @model.toJSON(), { @showAllLabels, @showActions }
    count = @getNetworkItemsCount()
    if count? then attrs.counter = { count, highlight: count > 0 }
    if attrs.extract? then attrs.description = attrs.extract
    return attrs

  getNetworkItemsCount: ->
    { itemsByCategory } = @model
    if itemsByCategory?
      return itemsByCategory.network.length + itemsByCategory.personal.length
    else
      return 0

  toggleZoom: ->
    _.invertAttr @ui.cover, 'src', 'data-zoom-toggle'
    @ui.zoomButtons.toggle()
    @$el.toggleClass 'zoom', { duration: 500 }
