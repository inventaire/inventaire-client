NoItem = require './no_item'

module.exports = Marionette.ItemView.extend
  className: 'inventoryWelcome'
  template: require './templates/inventory_welcome'
  events:
    'click a[href="/add"]': -> app.execute 'show:add:layout'
