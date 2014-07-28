module.exports = class PersonalInventoryTools extends Backbone.Marionette.ItemView
  template: require 'views/items/templates/personal_inventory_tools'
  events:
    'click #addItem': -> app.commands.execute 'item:create'