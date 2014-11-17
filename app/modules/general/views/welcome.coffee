module.exports = class Welcome extends Backbone.Marionette.LayoutView
  id: 'welcome'
  template: require './templates/welcome'
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
    # app.users will be override on Users module initialization
    app.users = {public: new app.Collection.Users}
    items = new app.Collection.Items
    _.preq.get app.API.items.public()
    .then (res)=>
      _.log res, 'Items.public res'
      app.users.public.add res.users
      items.add res.items
      itemsList = new app.View.ItemsList {collection: items}
      @right.show itemsList
    .fail (err)=>
      _.log err, 'couldnt loadPublicItems'
      @unsplitScreen()

  unsplitScreen: ->
    $('#welcome-right').hide()
    $('#welcome-left').parent()
    .removeClass('large-6').addClass('large-12')
    .hide().fadeIn(500)
