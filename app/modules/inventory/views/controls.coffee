module.exports = Marionette.ItemView.extend
  template: require './templates/controls'
  className: 'controls'
  ui:
    filter: 'input.filter'
    layoutTogglers: '.layouts a'
    cascade: '.cascade'
    grid: '.grid'

  events:
    'keyup input.filter': 'filterItems'
    'click .cascade': 'displayCascade'
    'click .grid': 'displayGrid'
    'click .showControls': 'toggleControls'

  initialize: -> @lastFilter = null
  onRender: ->
    @setActiveLayout()
    @recoverControls()

  setActiveLayout: (layout)->
    @ui.layoutTogglers.removeClass 'active'
    layout = layout or app.request 'inventory:layout'
    @ui[layout].addClass 'active'

  displayCascade: ->
    app.vent.trigger 'inventory:layout:change', 'cascade'
    @setActiveLayout 'cascade'

  displayGrid: ->
    app.vent.trigger 'inventory:layout:change', 'grid'
    @setActiveLayout 'grid'

  filterItems: ->
    text = @ui.filter.val()
    if text isnt @lastFilter
      @lastFilter = text
      app.execute 'filter:items:byText', text, false

  toggleControls: ->
    if @$el.hasClass 'displayed' then @wrapControls()
    else @displayControls()

  recoverControls: ->
    # boolean arrives as a string, thus the need to use JSON.parse
    bool = JSON.parse localStorage.getItem('controls:display')
    if bool then @displayControls() else @wrapControls()

  displayControls: ->
    @$el.addClass 'displayed'
    localStorage.setItem 'controls:display', true

  wrapControls: ->
    @$el.removeClass 'displayed'
    localStorage.setItem 'controls:display', false
