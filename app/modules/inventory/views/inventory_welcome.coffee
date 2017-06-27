NoItem = require './no_item'

module.exports = Marionette.ItemView.extend
  className: 'inventoryWelcome'
  template: require './templates/inventory_welcome'

  events:
    'click a[href="/add"]': 'showAddLayout'

  behaviors:
    PreventDefault: {}

  showAddLayout: (e)->
    unless _.isOpenedOutside e then app.execute 'show:add:layout:search'
