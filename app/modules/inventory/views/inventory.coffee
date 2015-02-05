SideNav = require '../side_nav/views/side_nav'
# ItemsLabel = require './items_label'
ItemsControl = require './items_control'

module.exports = class inventory extends Backbone.Marionette.LayoutView
  id: 'inventory'
  template: require './templates/inventory'
  regions:
    sideNav: '#sideNav'
    beforeItems: '#beforeItems'
    itemsView: '#itemsView'
    afterItems: '#afterItems'

  onShow: ->
    @sideNav.show new SideNav
    # waitForData to avoid having items displaying undefined values
    @showItemsListOnceData()


  showItemsListOnceData: ->
    app.request 'waitForFriendsItems', @showItemsList.bind(@)

  showItemsList: ->
    {items, user, welcomingNoItem, navigate} = @options
    docTitle = _.i18n('Home')
    eventName = 'general'

    if user?
      username = prepareUserItemsList(user, navigate)
      docTitle = eventName = username

    itemsList = new app.View.Items.List
      collection: Items.filtered.paginated
      columns: true
      welcomingNoItem: welcomingNoItem
    @itemsView.show itemsList

    app.vent.trigger 'document:title:change', docTitle
    app.vent.trigger 'inventory:change', eventName

    # @beforeItems.show new ItemsLabel
    @afterItems.show new ItemsControl


prepareUserItemsList = (user, navigate)->
  userModel = findUser(user)
  username = userModel.get('username')
  app.execute 'filter:inventory:owner', userModel.id
  app.execute 'sidenav:show:user', userModel
  if navigate? then app.navigate "inventory/#{username}"
  return username


findUser = (user)->
  if _.isModel(user) then return user
  else
    userame = user
    userModel = app.request('get:userModel:from:username', userame)
    if userModel? then return userModel
    else throw new Error("user model not found: got #{user}")