module.exports = class PersonalInventoryTools extends Backbone.Marionette.ItemView
  template: require 'views/items/templates/personal_inventory_tools'
  events:
    'click #addItem': -> app.execute 'show:entity:search'
    'keyup #itemsTextFilterField': 'executeTextFilter'
    'click #itemsTextFilterButton': 'executeTextFilter'
  serializeData: ->
    attrs =
      itemsTextFilter:
        nameBase: 'itemsTextFilter'
        field:
          placeholder: _.i18n 'Find an object'
        button:
          classes: 'secondary'
          text: _.i18n 'Search'
    return attrs

  executeTextFilter: ->
    app.execute 'textFilter', Items.personal.filtered, $('#itemsTextFilterField').val()