module.exports = class Contact extends Backbone.Marionette.ItemView
  tagName: "li"
  className: "contact"
  template: require 'views/contacts/templates/contact_li'

  events:
    'click #follow': -> app.commands.execute 'contact:follow', @model
    'mouseenter #unfollow': 'toggleClass'
    'mouseleave #unfollow': 'toggleClass'
    'click #unfollow': -> app.commands.execute 'contact:unfollow', @model
    'click .selectContact': -> app.commands.execute 'contact:fetchItems', @model


  initialize:->
    @listenTo @model, 'change:following', @render

  toggleClass: (e)->
    $(e.currentTarget)
    .toggleClass('alert').toggleClass('success')
    .find('i').toggleClass('fa-check').toggleClass('fa-minus').width(11)
