module.exports = Marionette.LayoutView.extend
  id: 'inventoryNetworkNav'
  template: require './templates/inventory_network_nav'

  regions:
    friendsList: '#friendsList'
    groupsList: '#groupsList'

  onShow: ->
    @showFriendsList()
    @showGroupsList()

  showFriendsList: ->
    app.request 'fetch:friends'
    .then @_showFriendsList.bind(@)

  _showFriendsList: (collection)->
    @friendsList.show new List { collection }

  showGroupsList: ->
    @groupsList.show new List { collection: app.groups }

ListEl = Marionette.ItemView.extend
  tagName: 'li'
  template: require './templates/inventory_network_nav_list_li'
  serializeData: ->
    attrs = @model.serializeData()
    attrs.isGroup = attrs.type is 'group'
    return attrs

  events:
    'click a': 'select'

  select: (e)->
    if _.isOpenedOutside e then return
    type = if @model.get('type') is 'group' then 'group' else 'user'
    app.vent.trigger "inventory:show:#{type}", @model
    e.preventDefault()

List = Marionette.CollectionView.extend
  tagName: 'ul'
  childView: ListEl
