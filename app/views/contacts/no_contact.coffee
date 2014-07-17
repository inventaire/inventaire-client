module.exports = class NoContact extends Backbone.Marionette.ItemView
  tagName: "li"
  className: "text-center hidden"
  template: require 'views/contacts/templates/no_contact'
  onShow: -> @$el.fadeIn()