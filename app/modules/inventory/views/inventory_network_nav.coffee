UserProfile = require 'modules/inventory/views/user_profile'
GroupProfile = require 'modules/network/views/group'
List = require 'modules/inventory/views/inventory_network_nav_list'

module.exports = Marionette.LayoutView.extend
  id: 'inventoryNetworkNav'
  template: require './templates/inventory_network_nav'

  regions:
    friendsList: '#friendsList'
    groupsList: '#groupsList'
    profile: '#profile'

  childEvents:
    select: (e, type, model)->
      @showProfile type, model
      @triggerMethod 'select', type, model

  onShow: ->
    @showFriendsList()
    @showGroupsList()
    { user, group } = @options
    if user? then @showProfile 'user', user
    else if group? then @showProfile 'group', group

  showFriendsList: ->
    app.request 'fetch:friends'
    .then @_showFriendsList.bind(@)

  _showFriendsList: (collection)->
    @friendsList.show new List { collection }

  showGroupsList: ->
    @groupsList.show new List { collection: app.groups }

  showProfile: (type, model)->
    if type is 'user' then @profile.show new UserProfile { model }
    if type is 'group' then @profile.show new GroupProfile { model, highlighted: true }
