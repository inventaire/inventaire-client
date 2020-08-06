ShelfItemsCandidates = require './shelf_items_candidate'
Items = require 'modules/inventory/collections/items'

module.exports = Marionette.CompositeView.extend
  id: 'shelfItemsAdder'
  template: require './templates/shelf_items_adder'
  childViewContainer: '.shelfItemsCandidates'
  childView: ShelfItemsCandidates
  childViewOptions: ->
    shelf: @options.model

  emptyView: require 'modules/entities/views/editor/autocomplete_no_suggestion'

  ui:
    candidates: '.shelfItemsCandidates'

  initialize: ->
    @collection = new Items
    @offset = 0
    @limit = 20
    @suggestLastItems()

  onShow: ->
    app.execute 'modal:open'
    # Doesn't work if set in events for some reason
    @ui.candidates.on 'scroll', @onScroll.bind(@)

  events:
    'click .create': 'create'
    'click .done': 'onDone'
    'keydown #searchCandidates': 'lazySearch'

  lazySearch: (e)->
    @_lazySearch ?= _.debounce @search.bind(@), 200
    @_lazySearch(e)

  search: (e)->
    { value: input } = e.currentTarget
    input = input.trim()

    if input is ''
      if @_lastInput?
        @_lastInput = null
        @offset = 0
        @suggestLastItems()
        return
      else
        @$el.removeClass 'fetching'
        return

    @_lastMode = 'search'
    @_lastInput = input
    @$el.addClass 'fetching'

    _.preq.get app.API.items.search(app.user.id, input)
    .then ({ items })=>
      @offset += @limit
      if @_lastInput is input
        @$el.removeClass 'fetching'
        @collection.reset items

  onScroll: (e)->
    visibleHeight = @ui.candidates.height()
    { scrollHeight, scrollTop } = e.currentTarget
    scrollBottom = scrollTop + visibleHeight
    if scrollBottom is scrollHeight then @fetchMore()

  suggestLastItems: ->
    @$el.addClass 'fetching'
    @_lastMode = 'last'
    app.request 'items:getUserItems', { model: app.user, @offset, @limit }
    .then ({ items })=>
      if @_lastMode is 'last'
        @$el.removeClass 'fetching'
        if @offset is 0 then @collection.reset items
        else @collection.add items

  fetchMore: ->
    if @_lastMode is 'last'
      @offset += @limit
      @suggestLastItems()

  # Known limitation: this function will only be called when the user clicks
  # the 'done' button, not when closing the modal by clicking the 'close' or
  # clicking outside the modal; meaning that in those case, the shelf inventory
  # won't be refreshed
  onDone: ->
    # Refresh the shelf data
    app.vent.trigger 'inventory:select', 'shelf', @model
    app.execute 'modal:close'
