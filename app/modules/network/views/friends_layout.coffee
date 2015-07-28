UsersList = require 'modules/users/views/users_list'
behaviorsPlugin = require 'modules/general/plugins/behaviors'

module.exports = Marionette.LayoutView.extend
  template: require './templates/friends_layout'
  id: 'friendsLayout'
  tagName: 'section'

  regions:
    friendsRequests: '#friendsRequests'
    friendsList: '#friendsList'

  ui:
    friendsRequestsHeader: '#friendsRequestsHeader'

  behaviors:
    Loading: {}

  onShow: ->
    behaviorsPlugin.startLoading.call @, '#friendsList'
    app.request('waitForFriendsItems')
    .then @showFriendsLists.bind(@)
    .catch _.Error('showTabFriends')

  showFriendsLists: ->
    @showFriendsRequests()
    @showFriendsList()

  showFriendsRequests: ->
    { otherRequested } = app.users
    if otherRequested.length > 0
      @friendsRequests.show new UsersList
        collection: otherRequested
        emptyViewMessage: 'no pending requests'
    else
      @ui.friendsRequestsHeader.hide()

  showFriendsList: ->
    @friendsList.show new UsersList
      collection: app.users.friends
      emptyViewMessage: "you aren't connected to anyone yet"
