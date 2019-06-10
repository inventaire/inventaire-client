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
    app.execute 'uriLabel:update'

    { @showAllLabels, @showActions, @wrap, preventRerender } = @options
    @showActions ?= true
    preventRerender ?= false

    # Allow to disable re-render for views that are used as part of layouts that store state
    # in the DOM - such as ./deduplicate_layout - so that this state isn't lost
    if preventRerender then return

    @lazyRender = _.LazyRender @

    if @model.usesImagesFromSubEntities
      @model.fetchSubEntities()
      @listenTo @model, 'change:image', @lazyRender

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
