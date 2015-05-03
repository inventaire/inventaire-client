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

  onRender: ->
    @setActiveLayout()

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
    app.execute 'filter:items:byText', text
