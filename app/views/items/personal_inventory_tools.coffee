module.exports = class PersonalInventoryTools extends Backbone.Marionette.ItemView
  template: require 'views/items/templates/personal_inventory_tools'
  events:
    'click #addItem': 'showItemCreationForm'

  showItemCreationForm: ->
    app.layout.modal.show new app.View.ItemCreationForm