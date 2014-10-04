module.exports = class ContactsInventoryTools extends Backbone.Marionette.ItemView
  template: require 'views/items/templates/contacts_inventory_tools'
  events:
    'keyup #itemsTextFilterField': 'executeTextFilter'
    'click #itemsTextFilterButton': 'executeTextFilter'
    'keyup #contactSearchField': 'executeContactSearch'
    'click #contactSearchButton': 'executeContactSearch'
  serializeData: ->
    attrs =
      contactSearch:
        nameBase: 'contactSearch'
        field:
          placeholder: _.i18n 'Find Contacts'
        button:
          classes: 'secondary'
          text: _.i18n 'Search Contacts'

      itemsTextFilter:
        nameBase: 'itemsTextFilter'
        field:
          placeholder: _.i18n 'Find an object'
        button:
          classes: 'secondary'
          text: _.i18n 'Search'
    return attrs

  executeTextFilter: ->
    app.execute 'textFilter', Items.contacts.filtered, $('#itemsTextFilterField').val()

  executeContactSearch: ->
    app.execute 'contactSearch', $('#contactSearchField').val()