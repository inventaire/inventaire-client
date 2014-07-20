module.exports = class Contact extends Backbone.Marionette.ItemView
  tagName: "li"
  className: "contact row"
  template: require 'views/contacts/templates/contact_li'

  events:
    'click #follow': -> app.commands.execute 'contact:follow', @model.get('_id')