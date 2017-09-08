getActionKey = require 'lib/get_action_key'

BrowserSelectorLi = Marionette.ItemView.extend
  tagName: 'li'
  className: 'browser-selector-li'
  template: require './templates/browser_selector_li'

module.exports = Marionette.CompositeView.extend
  className: 'browser-selector'
  template: require './templates/browser_selector'
  childViewContainer: 'ul'
  childView: BrowserSelectorLi

  initialize: ->
    @listenTo app.vent, 'body:click', @hideOptions.bind(@)
    @listenTo app.vent, 'browser:selector:click', @hideOptions.bind(@)

  ui:
    filterField: 'input[name="filter"]'

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

  _updateFilter: (e)-> @collection.filterByText e.target.value

  hideOptions: (cid)->
    unless cid is @cid then @$el.removeClass 'showOptions'

  toggleOptions: (e)->
    @$el.toggleClass 'showOptions'
    @ui.filterField.focus()
    app.vent.trigger 'browser:selector:click', @cid
    e.stopPropagation()

  keyAction: (e)->
    key = getActionKey e
    switch key
      when 'esc' then @hideOptions()
      # TODO:
      # when 'down' then @focusDown()
      # when 'up' then @focusUp()
