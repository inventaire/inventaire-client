UsersList = require 'modules/users/views/users_list'
Users = require 'modules/users/collections/users'
behaviorsPlugin = require 'modules/general/plugins/behaviors'

module.exports = Marionette.LayoutView.extend
  template: require './templates/friends_layout'
  id: 'friendsLayout'
  tagName: 'section'

  regions:
    friendsRequests: '#friendsRequests'
    friendsList: '#friendsList'

  ui:
    friendsRequestsWrapper: '.friends-requests-wrapper'
    friendsFilterWrapper: '.friends-filter-wrapper'
    friendsFilter: '#friendsFilter'

  behaviors:
    Loading: {}
    PreventDefault: {}

  initialize: ->
    @waitForFriends = app.request 'fetch:friends'
      .then => @friends = app.users.friends.filtered

    @waitForOtherRequested = app.request 'fetch:otherRequested'
      .then => @otherRequested = app.users.otherRequested

  events:
    'keyup #friendsFilter': 'filterFriends'

  serializeData: ->
    friendsFilter:
      id: 'friendsFilter'
      placeholder: 'search for your friends'

  onRender: ->
    behaviorsPlugin.startLoading.call @, '#friendsList'

    @waitForFriends
    .then @showFriends.bind(@)
    .catch _.Error('showTabFriends')

  showFriends: ->
    @waitForOtherRequested
    .then @ifViewIsIntact('showFriendsRequests')

    @showFriendsFilter()
    @showFriendsLists()

  showFriendsRequests: ->
    if @otherRequested.length > 0
      @ui.friendsRequestsWrapper.show()
      @friendsRequests.show new UsersList
        collection: @otherRequested
        emptyViewMessage: 'no pending requests'
        stretch: true

  showFriendsFilter: ->
    if @friends.length > 8 then @ui.friendsFilterWrapper.show()

  filterFriends: ->
    text = @ui.friendsFilter.val()
    @friends.filterByText text

  showFriendsLists: ->
    @friends.resetFilters()
    @friendsList.show new UsersList
      collection: @friends
      emptyViewMessage: "you aren't connected to anyone yet"
      emptyViewLink: 'inviteFriends'
      stretch: true
