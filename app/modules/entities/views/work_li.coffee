module.exports = Marionette.ItemView.extend
  template: require './templates/work_li'
  className: ->
    prefix = @model.get 'prefix'
    @wrap ?= @options.wrap
    wrap = if @wrap then 'wrapped wrappable' else ''
    "workLi entity-prefix-#{prefix} #{wrap}"

  attributes: ->
    # Used by deduplicate_layout
    'data-uri': @model.get('uri')

  initialize: ->
    @lazyRender = _.LazyRender @
    @listenTo @model, 'change', @lazyRender
    app.execute 'uriLabel:update'

    { @showAllLabels, @showActions, @wrap } = @options
    @showActions ?= true

    if @showActions
      # Required by @getNetworkItemsCount
      @model.getItemsByCategories()
      .then @lazyRender

  behaviors:
    PreventDefault: {}

  ui:
    zoomButtons: '.zoom-buttons span'
    cover: 'img'

  events:
    'click a.addToInventory': 'showItemCreationForm'
    'click .zoom-buttons': 'toggleZoom'
    'click': 'toggleWrap'

  onRender: ->
    @updateClassName()

  showItemCreationForm: (e)->
    unless _.isOpenedOutside(e)
      app.execute 'show:item:creation:form', { entity: @model }

  serializeData: ->
    attrs = _.extend @model.toJSON(), { @showAllLabels, @showActions, @wrap }
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

  toggleZoom: (e)->
    _.invertAttr @ui.cover, 'src', 'data-zoom-toggle'
    @ui.zoomButtons.toggle()
    @$el.toggleClass 'zoom', { duration: 500 }
    e.stopPropagation()
    e.preventDefault()

  toggleWrap: (e)->
    if @$el.hasClass 'wrapped'
      @wrap = false
      @$el.removeClass 'wrapped'
      @$el.addClass 'unwrapped'
    else if @$el.hasClass 'unwrapped'
      @wrap = true
      @$el.removeClass 'unwrapped'
      @$el.addClass 'wrapped'
