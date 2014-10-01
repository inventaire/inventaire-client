module.exports = class Welcome extends Backbone.Marionette.LayoutView
  id: 'welcome'
  template: require 'views/templates/welcome'
  regions:
    left: '#welcome-left'
    right: '#welcome-right'
    loginButtons: '#loginButtons'

  onShow: ->
    buttons = new app.View.NotLoggedMenu
    @loginButtons.show buttons
    @$el.find('li').addClass 'button'

    @loadPublicItems()

  loadPublicItems: ->
    # app.contacts will be override on Contacts module initialization
    app.contacts = new app.Collection.Contacts
    items = new app.Collection.Items
    $.getJSON(app.API.items.public())
    .then (res)=>
      _.log res, 'Items.public res'
      app.contacts.add res.users
      items.add res.items
      itemsList = new app.View.ItemsList {collection: items}
      @right.show itemsList
    .fail (err)->
      _.log err, 'couldnt loadPublicItems'
      @unsplitScreen()

  unsplitScreen: ->
    $('#welcome-right').hide()
    $('#welcome-left').parent()
    .removeClass('large-6').addClass('large-12')
    .hide().fadeIn(500)
