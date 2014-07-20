module.exports = class Contact extends Backbone.Marionette.ItemView
  tagName: "li"
  className: "contact row"
  template: require 'views/contacts/templates/contact_li'

  initialize: ->
    if app.contacts.indexOf @model._id isnt -1
      @model.set 'following', true

  events:
    'click #follow': -> app.commands.execute 'contact:new', @model.get('_id')