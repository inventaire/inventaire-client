UsersList = require 'modules/users/views/users_list'
GroupsList = require './groups_list'
GroupCreationForm = require './group_creation_form'
behaviorsPlugin = require 'modules/general/plugins/behaviors'

module.exports = Marionette.LayoutView.extend
  template: require './templates/groups_layout'
  id: 'groupsLayout'
  tagName: 'section'

  regions:
    groupsInvitations: '#groupsInvitations'
    groupList: '#groupsList'
    groupCreation: '#groupCreation'

  ui:
    groupsInvitationsHeader: '#groupsInvitationsHeader'

  behaviors:
    Loading: {}

  onShow: ->
    behaviorsPlugin.startLoading.call @, '#groupsList'
    app.request('waitForFriendsItems')
    .then @showGroupsLists.bind(@)
    .catch _.Error('showTabGroups')

    @showGroupCreationForm()

  showGroupsLists: ->
    @showGroupsInvitations()
    @showGroupsList()

  showGroupsInvitations: ->
    { mainUserInvited } = app.user.groups
    if mainUserInvited.length > 0
      @ui.groupsInvitationsHeader.show()
      @groupsInvitations.show new GroupsList
        collection: mainUserInvited
        showBoards: true
        emptyViewMessage: "you have no pending invitation to join a group"

  showGroupsList: ->
    @groupList.show new GroupsList
      collection: app.user.groups.mainUserMember
      showBoards: true

  showGroupCreationForm: ->
    @groupCreation.show new GroupCreationForm
