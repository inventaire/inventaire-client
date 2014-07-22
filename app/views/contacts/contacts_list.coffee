module.exports = class ContactsList extends Backbone.Marionette.CollectionView
  tagName: 'ul'
  className: 'contactList'
  childView: require 'views/contacts/contact_li'
  emptyView: require 'views/contacts/no_contact'