UsersList = require 'modules/users/views/users_list'
GroupsList = require './groups_list'
behaviorsPlugin = require 'modules/general/plugins/behaviors'

module.exports = Marionette.LayoutView.extend
  template: require './templates/groups_layout'
  id: 'groupsLayout'
  tagName: 'section'

  regions:
    groupsInvitations: '#groupsInvitations'
    groupList: '#groupsList'

  behaviors:
    Loading: {}

  onShow: ->
    behaviorsPlugin.startLoading.call @, '#groupsList'
    app.request('waitForFriendsItems')
    .then @showGroupsLists.bind(@)
    .catch _.Error('showTabGroups')

  showGroupsLists: ->
    @showGroupsInvitations()
    @showGroupsList()

  showGroupsInvitations: ->
    { mainUserInvited } = app.groups
    if mainUserInvited.length > 0
      @groupsInvitations.show new GroupsList
        collection: mainUserInvited
        mode: 'board'
        emptyViewMessage: "you have no more pending invitations"

  showGroupsList: ->
    @groupList.show new GroupsList
      collection: app.groups.mainUserMember
      mode: 'board'
