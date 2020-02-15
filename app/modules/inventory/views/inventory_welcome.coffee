NoItem = require './no_item'

module.exports = Marionette.ItemView.extend
  className: 'inventoryWelcome'
  template: require './templates/inventory_welcome'

  events:
    'click a[href="/add"]': _.clickCommand 'show:add:layout:search'

  behaviors:
    PreventDefault: {}
