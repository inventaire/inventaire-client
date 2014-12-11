SideNav = require '../side_nav/views/side_nav'

module.exports = class inventory extends Backbone.Marionette.LayoutView
  id: 'inventory'
  template: require './templates/inventory'
  regions:
    sideNav: '#sideNav'
    itemsView: '#itemsView'

  onShow: ->
    @sideNav.show new SideNav
    $('#inventorySections').slideDown(1000)
