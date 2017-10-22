getActionKey = require 'lib/get_action_key'
BrowserSelectorLi = require './browser_selector_li'

module.exports = Marionette.CompositeView.extend
  className: 'browser-selector'
  attributes: ->
    # Value used as a CSS selector: [data-options="0"]
    'data-options': @collection.length

  template: require './templates/browser_selector'
  childViewContainer: 'ul'
  childView: BrowserSelectorLi

  initialize: ->
    @selectorName = @options.name
    # Prevent the filter to re-filter (thus re-rendering the collection)
    # if the first value is ''
    @_lastValue = ''

    @listenTo app.vent, 'body:click', @hideOptions.bind(@)
    @listenTo app.vent, 'browser:selector:click', @hideOptions.bind(@)

  ui:
    filterField: 'input[name="filter"]'
    optionsList: '.options ul'
    selectorButton: '.selector-button'
    defaultMode: '.defaultMode'
    selectedMode: '.selectedMode'
    count: '.count'

  serializeData: ->
    name: @selectorName
    showFilter: @collection.length > 5
    count: @collection.length

  events:
    'keydown input[name="filter"]': 'updateFilter'
    'click .selector-button': 'toggleOptions'
    'keydown': 'keyAction'
    # Prevent that a click to focus the input triggers a 'body:click' event
    'click': (e)-> e.stopPropagation()

  childEvents:
    'select': 'selectOption'

  updateFilter: (e)->
    @lazyUpdateFilter or= _.debounce @_updateFilter.bind(@), 150
    @lazyUpdateFilter e

  _updateFilter: (e)->
    { value } = e.target
    if value is @_lastValue then return
    @_lastValue = value
    @collection.filterByText value

  showOptions: ->
    @$el.addClass 'showOptions'
    @ui.filterField.focus()
    app.vent.trigger 'browser:selector:click', @cid

  # Pass a view cid if that specific view shouldn't hide its options
  # Used to close all selectors but one
  hideOptions: (cid)->
    unless cid is @cid then @$el.removeClass 'showOptions'

  toggleOptions: (e)->
    { classList } = e.target

    # Handle clicks on the 'x' close button
    if classList? and 'fa-times' in classList then return @resetOptions()

    # When an option is already selected, the only option is to unselect it
    if @_selectedOption? then return

    if @$el.hasClass('showOptions') then @hideOptions()
    else @showOptions()

    e.stopPropagation()

  keyAction: (e)->
    key = getActionKey e

    if @_selectedOption?
      switch key
        when 'esc', 'enter' then @resetOptions()

    else
      switch key
        when 'esc' then @hideOptions()
        when 'enter' then @clickCurrentlySelected e
        when 'down' then @selectSibling e, 'next'
        when 'up' then @selectSibling e, 'prev'

  selectSibling: (e, relation)->
    @showOptions()
    $selected = @$el.find '.selected'
    if $selected.length is 1
      $selected.removeClass 'selected'
      $newlySelected = $selected[relation]()
      $newlySelected.addClass 'selected'
    else
      # If none is selected, depending of the arrow direction,
      # select the first or the last
      position = if relation is 'next' then 'first' else 'last'
      @$el.find('.browser-selector-li')[position]().addClass 'selected'

    # Adjust scroll to the selected element
    _.innerScrollTop @ui.optionsList, @$el.find('.selected')

    # Prevent arrow keys to make the screen move
    e.preventDefault()

  clickCurrentlySelected: -> @$el.find('.selected').trigger 'click'

  selectOption: (view, model)->
    @_selectedOption = model
    @triggerMethod 'filter:select', model
    labelSpan = "<span class='label'>#{model.get('label')}</span>"
    @ui.selectedMode.html labelSpan + _.icon('times')
    @hideOptions()
    @ui.selectorButton.addClass 'active'

  resetOptions: ->
    @_selectedOption = null
    @triggerMethod 'filter:select', null
    @ui.selectorButton.removeClass 'active'
    @hideOptions()
    @collection.removeFilter 'text'
    @updateCounter()

  filterOptions: (intersectionWorkUris)->
    if not intersectionWorkUris? then @collection.removeFilter 'intersection'
    # Do not re-filter if this selector already has a selected option
    else if @_selectedOption? then return
    else
      { treeSection } = @options
      ownerSelector = @selectorName is 'owner'
      treeKey = if ownerSelector then '_id' else 'uri'
      @collection.filterBy 'intersection', (model)->
        key = model.get treeKey
        worksUris = treeSection[key]
        if worksUris? then return _.haveAMatch worksUris, intersectionWorkUris
        # Known cases without worksUris: groups, nearby users
        else return false

    @updateCounter()

  updateCounter: ->
    remainingCount = @collection.length
    @ui.count.text "(#{remainingCount})"
    @$el.attr 'data-options', remainingCount
