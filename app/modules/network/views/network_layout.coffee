UsersList = require 'modules/users/views/users_list'
GroupsList = require './groups_list'
GroupCreationForm = require './group_creation_form'
behaviorsPlugin = require 'modules/general/plugins/behaviors'

module.exports = Marionette.LayoutView.extend
  template: require './templates/network_layout'
  id: 'networkLayout'

  regions:
    friendsRequests: '#friendsRequests'
    friendsList: '#friendsList'
    groupsInvitations: '#groupsInvitations'
    groupList: '#groupsList'
    groupCreation: '#groupCreation'

  ui:
    tabs: '.custom-tabs-titles a'
    contents: '.custom-tabs-content section'
    friendsTab: '#friendsTab'
    friendsContent: '#friendsContent'
    friendsRequestsHeader: '#friendsRequestsHeader'
    groupsTab: '#groupsTab'
    groupsContent: '#groupsContent'
    groupsInvitationsHeader: '#groupsInvitationsHeader'

  behaviors:
    Loading: {}

  events:
    'click #friendsTab': 'showTabFriends'
    'click #groupsTab': 'showTabGroups'

  onShow: ->
    if @options.tab is 'groups' then @showTabGroups()
    else @showTabFriends()

  showTabFriends: ->
    @updateTabs 'friends'
    app.navigate "network/friends"
    behaviorsPlugin.startLoading.call @, '#friendsList'
    app.request('waitForFriendsItems')
    .then @showFriendsLists.bind(@)
    .catch _.Error('showTabFriends')

  showTabGroups: ->
    @updateTabs 'groups'
    app.navigate "network/groups"
    behaviorsPlugin.startLoading.call @, '#groupsList'
    app.request('waitForFriendsItems')
    .then @showGroupsLists.bind(@)
    .catch _.Error('showTabGroups')

    @showGroupCreationForm()

  updateTabs: (tab)->
    @ui.tabs.removeClass 'active'
    @ui.contents.hide()
    @ui["#{tab}Tab"].addClass 'active'
    @ui["#{tab}Content"].show()

  showFriendsLists: ->
    @showFriendsRequests()
    @showFriendsList()

  showGroupsLists: ->
    @showGroupsInvitations()
    @showGroupsList()

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

  showGroupsInvitations: ->
    { mainUserInvited } = app.user.groups
    if mainUserInvited.length > 0
      @groupsInvitations.show new GroupsList
        collection: mainUserInvited
        showBoards: true
        emptyViewMessage: "you have no pending invitation to join a group"
    else
      @ui.groupsInvitationsHeader.hide()

  showGroupsList: ->
    @groupList.show new GroupsList
      collection: app.user.groups.mainUserMember
      showBoards: true


  showGroupCreationForm: ->
    @groupCreation.show new GroupCreationForm
