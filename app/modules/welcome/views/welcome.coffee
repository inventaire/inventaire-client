NotLoggedMenu = require 'modules/general/views/menu/not_logged_menu'

module.exports = class Welcome extends Backbone.Marionette.LayoutView
  id: 'welcome'
  template: require './templates/welcome'
  regions:
    previewColumns: '#previewColumns'

  initialize: ->
    # importing loggin buttons events
    @events = NotLoggedMenu::events

  serializeData: ->
    loggedIn: app.user.loggedIn

  ui:
    topBarTrigger: '#middle-three'

  onShow: ->
    @loadPublicItems()
    unless app.user.loggedIn
      @hideTopBar()
      @ui.topBarTrigger.once 'inview', @showTopBar


  onDestroy: -> @showTopBar()

  loadPublicItems: ->
    _.preq.get app.API.items.public()
    .catch _.preq.catch404
    .then (res)=>
      if res?.items?.length > 0
        _.log res, 'Items.public res'
        app.users.public.add res.users
        items = new app.Collection.Items
        items.add res.items
        itemsColumns = new app.View.Items.List
          collection: items
          columns: true
        @previewColumns.show itemsColumns
      else @hidePublicItems()
    .catch (err)=>
      @hidePublicItems()
      _.log err, 'couldnt loadPublicItems'
    .catch (err)-> _.error err, 'hidePublicItems err'

  hidePublicItems: -> $('#welcome-two').hide()

  hideTopBar: -> $('.top-bar').hide()
  showTopBar: -> $('.top-bar').slideDown()
