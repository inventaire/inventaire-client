module.exports = class ContactsList extends Backbone.Marionette.CollectionView
  childView: require 'views/contacts/contact_li'
  emptyView: require 'views/contacts/no_contact'