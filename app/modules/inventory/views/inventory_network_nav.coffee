List = require 'modules/inventory/views/inventory_network_nav_list'

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
