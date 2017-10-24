getActionKey = require 'lib/get_action_key'
BrowserSelectorOptions = require './browser_selector_options'

module.exports = Marionette.LayoutView.extend
  className: 'browser-selector'
  attributes: ->
    # Value used as a CSS selector: [data-options="0"]
    'data-options': @count()

  template: require './templates/browser_selector'
  regions:
    list: '.list'

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
    showFilter: @count() > 5
    count: @count()

  # Overriden in subclasses
  count: -> @collection.length

  onShow: ->
    @list.show new BrowserSelectorOptions { @collection }

  events:
    'keydown input[name="filter"]': 'updateFilter'
    'click .selector-button': 'toggleOptions'
    'keydown': 'keyAction'
    # Prevent that a click to focus the input triggers a 'body:click' event
    'click input': (e)-> e.stopPropagation()

  childEvents:
    'select': 'selectOption'

  updateFilter: (e)->
    @lazyUpdateFilter or= _.debounce @_updateFilter.bind(@), 150
    @lazyUpdateFilter e

  _updateFilter: (e)->
    { value } = e.target
    if value is @_lastValue then return
    @_lastValue = value
    @collectionsAction 'filterByText', value

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

  # In the simplest case, navigable elements are all childrens of the same parent
  # but ./browser_owners_selector has a more complex case
  arrowNavigationSelector: '.browser-selector-li'

  selectSibling: (e, relation)->
    @showOptions()
    $arrowNavigationElements = @$el.find @arrowNavigationSelector
    $selected = @$el.find '.selected'
    if $selected.length is 1
      currentIndex = $arrowNavigationElements.index $selected
      $selected.removeClass 'selected'
      newIndex = if relation is 'next' then currentIndex+1 else currentIndex-1
      $newlySelected = $arrowNavigationElements.eq newIndex
      $newlySelected.addClass 'selected'
    else
      # If none is selected, depending of the arrow direction,
      # select the first or the last
      position = if relation is 'next' then 'first' else 'last'
      @$el.find(@arrowNavigationSelector)[position]().addClass 'selected'

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
    @collectionsAction 'removeFilter', 'text'
    @updateCounter()

  treeKeyAttribute: 'uri'

  filterOptions: (intersectionWorkUris)->
    if not intersectionWorkUris? then @collectionsAction 'removeFilter', 'intersection'
    # Do not re-filter if this selector already has a selected option
    else if @_selectedOption? then return
    else
      { treeSection } = @options
      filter = @_intersectionFilter.bind @, treeSection, intersectionWorkUris
      @collectionsAction 'filterBy', 'intersection', filter

    @updateCounter()

  _intersectionFilter: (treeSection, intersectionWorkUris, model)->
    if intersectionWorkUris.length is 0 then return false
    key = model.get @treeKeyAttribute
    worksUris = treeSection[key]
    # Known cases without worksUris: groups, nearby users
    unless worksUris? then return false

    count = @getIntersectionCount key, worksUris, intersectionWorkUris
    if count is 0 then return false

    # Set intersectionCount so that ./browser_selector_li can re-render
    # with an updated count
    model.set 'intersectionCount', count
    return true

  getIntersectionCount: (key, worksUris, intersectionWorkUris)->
    _.intersection(worksUris, intersectionWorkUris).length

  # To be overriden in subclasses that need to handle several collections
  collectionsAction: (fnName, args...)-> @collection[fnName](args...)

  updateCounter: ->
    remainingCount = @count()
    @ui.count.text "(#{remainingCount})"
    @$el.attr 'data-options', remainingCount
