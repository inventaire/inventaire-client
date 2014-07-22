module.exports = class Contact extends Backbone.Marionette.ItemView
  tagName: "li"
  className: "contact row"
  template: require 'views/contacts/templates/contact_li'

  events:
    'click #follow': -> app.commands.execute 'contact:follow', @model
    'mouseenter #unfollow': 'toggleClass'
    'mouseleave #unfollow': 'toggleClass'
    'click #unfollow': -> app.commands.execute 'contact:unfollow', @model
    'click .selectContact': 'togglerSelectContact'

  initialize:->
    @listenTo @model, 'change:following', @render

  toggleClass: (e)->
    $(e.currentTarget)
    .toggleClass('alert').toggleClass('success')
    .find('i').toggleClass('fa-check').toggleClass('fa-minus').width(11)

  togglerSelectContact: (e)->
    if @$el.hasClass('selected')
      @unselectContact()
    else
      @selectContact()

  selectContact: ->
    app.commands.execute 'contact:fetchItems', @model unless @model.get('following')
    app.commands.execute 'filter:inventory:owner', @model.id
    $('.selected').removeClass('selected')
    @$el.addClass('selected')

  unselectContact: ->
    app.filteredItems.removeFilter 'owner'
    @$el.removeClass('selected')
