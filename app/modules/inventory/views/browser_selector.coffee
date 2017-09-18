getActionKey = require 'lib/get_action_key'
BrowserSelectorLi = require './browser_selector_li'

module.exports = Marionette.CompositeView.extend
  className: 'browser-selector'
  template: require './templates/browser_selector'
  childViewContainer: 'ul'
  childView: BrowserSelectorLi

  initialize: ->
    @listenTo app.vent, 'body:click', @hideOptions.bind(@)
    @listenTo app.vent, 'browser:selector:click', @hideOptions.bind(@)
    # Prevent the filter to re-filter (thus re-rendering the collection)
    # if the first value is ''
    @_lastValue = ''

  ui:
    filterField: 'input[name="filter"]'
    optionsList: '.options ul'

  serializeData: ->
    name: @options.name
    showFilter: @collection.length > 5
    count: @collection.length

  events:
    'keydown input[name="filter"]': 'updateFilter'
    'click .selector-button': 'toggleOptions'
    'keydown': 'keyAction'
    # Prevent that a click to focus the input triggers a 'body:click' event
    'click': (e)-> e.stopPropagation()

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

  hideOptions: (cid)->
    unless cid is @cid then @$el.removeClass 'showOptions'

  toggleOptions: (e)->
    if @$el.hasClass('showOptions') then @hideOptions()
    else @showOptions()
    e.stopPropagation()

  keyAction: (e)->
    key = getActionKey e
    switch key
      when 'esc' then @hideOptions()
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
    $selected = @$el.find '.selected'
    if $selected.length > 0
      selectedTop = @$el.find('.selected').position().top
      # Adjust scroll to the selected element
      scrollTop = @ui.optionsList.scrollTop() + selectedTop - 50
    else
      scrollTop = 0
    @ui.optionsList.animate({ scrollTop }, scrollOptions)

    # Prevent arrow keys to make the screen move
    e.preventDefault()

scrollOptions = { duration: 50, easing: 'swing' }
