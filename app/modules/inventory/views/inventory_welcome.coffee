NoItem = require './no_item'

module.exports = Backbone.Marionette.ItemView.extend
  className: "inventoryWelcome"
  template: require './templates/inventory_welcome'
  events:
    'click #jumpIn': -> app.execute 'show:joyride:welcome:tour'
