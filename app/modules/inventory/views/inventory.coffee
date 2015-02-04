SideNav = require '../side_nav/views/side_nav'

module.exports = class inventory extends Backbone.Marionette.LayoutView
  id: 'inventory'
  template: require './templates/inventory'
  regions:
    sideNav: '#sideNav'
    itemsView: '#itemsView'

  onShow: ->
    @sideNav.show new SideNav
    # waitForData to avoid having items displaying undefined values
    @showItemsListOnceData()

  showItemsListOnceData: ->
    app.request 'waitForData', @showItemsList.bind(@)

  showItemsList: ->
    {items, user, welcomingNoItem, navigate} = @options
    docTitle = _.i18n('Home')
    eventName = 'general'

    if user?
      userModel = findUser(user)
      docTitle = eventName = username = userModel.get('username')
      app.execute 'filter:inventory:owner', items, userModel.id
      app.execute 'sidenav:show:user', userModel
      if navigate? then app.navigate "inventory/#{username}"

    itemsList = new app.View.Items.List
      collection: items
      columns: true
      welcomingNoItem: welcomingNoItem
    @itemsView.show itemsList

    app.vent.trigger 'document:title:change', docTitle
    app.vent.trigger 'inventory:change', eventName



findUser = (user)->
  if _.isModel(user) then return user
  else
    userame = user
    userModel = app.request('get:userModel:from:username', userame)
    if userModel? then return userModel
    else throw new Error("user model not found: got #{user}")