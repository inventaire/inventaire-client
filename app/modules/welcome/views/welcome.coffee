module.exports = class Welcome extends Backbone.Marionette.LayoutView
  id: 'welcome'
  template: require './templates/welcome'
  regions:
    previewColumns: '#previewColumns'

  initialize: ->
    # importing loggin buttons events
    @events = app.View.NotLoggedMenu::events

  onShow: ->
    @loadPublicItems()
    $('.top-bar').hide()
  onDestroy: ->
    $('.top-bar').fadeIn()

  loadPublicItems: ->
    _.preq.get app.API.items.public()
    .then (res)=>
      _.log res, 'Items.public res'
      app.users.public.add res.users
      items = new app.Collection.Items
      items.add res.items
      itemsColumns = new app.View.ItemsList
        collection: items
        columns: true
      @previewColumns.show itemsColumns
    .fail (err)=>
      $('#welcome-two').find('h3').hide()
      _.log err, 'couldnt loadPublicItems'