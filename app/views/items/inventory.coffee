module.exports = class inventory extends Backbone.Marionette.LayoutView
  id: 'inventory'
  template: require 'views/items/templates/inventory'
  regions:
    topMenu: '#topmMenu'
    viewTools: '#viewTools'
    itemsView: '#itemsView'
    sideMenu: '#sideMenu'

  events:
    # not delegated to tools view as used in several ones
    'keyup #itemsTextFilterField': 'executeTextFilter'
    'click #itemsTextFilterButton': 'executeTextFilter'
    'keyup #contactSearchField': 'executeContactSearch'
    'click #contactSearchButton': 'executeContactSearch'

  executeTextFilter: ->
    app.execute 'textFilter', $('#itemsTextFilterField').val()

  executeContactSearch: ->
    app.execute 'contactSearch', $('#contactSearchField').val()