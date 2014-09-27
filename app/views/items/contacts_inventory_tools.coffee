module.exports = class ContactsInventoryTools extends Backbone.Marionette.ItemView
  template: require 'views/items/templates/contacts_inventory_tools'
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