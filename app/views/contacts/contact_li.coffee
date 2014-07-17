module.exports = class Contact extends Backbone.Marionette.ItemView
  tagName: "li"
  className: "contact row"
  template: require 'views/contacts/templates/contact_li'
  initialize: ->
    console.log 'contact li!'