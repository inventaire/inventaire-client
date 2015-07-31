UsersList = require 'modules/users/views/users_list'
behaviorsPlugin = require 'modules/general/plugins/behaviors'
UsersSearch = require 'modules/network/plugins/users_search'

module.exports = Marionette.LayoutView.extend
  template: require './templates/friends_layout'
  id: 'friendsLayout'
  tagName: 'section'

  regions:
    friendsRequests: '#friendsRequests'

  ui:
    friendsRequestsHeader: '#friendsRequestsHeader'

  behaviors:
    Loading: {}

  initialize: ->
    @initPlugins()

  initPlugins: ->
    UsersSearch.call @

  onShow: ->
    behaviorsPlugin.startLoading.call @, '#usersList'
    app.request('waitForFriendsItems')
    .then @showFriendsLists.bind(@)
    .catch _.Error('showTabFriends')

  showFriendsLists: ->
    @showFriendsRequests()
    @showUsersSearchBase()

  showFriendsRequests: ->
    { otherRequested } = app.users
    if otherRequested.length > 0
      @friendsRequests.show new UsersList
        collection: otherRequested
        emptyViewMessage: 'no pending requests'
    else
      @ui.friendsRequestsHeader.hide()
