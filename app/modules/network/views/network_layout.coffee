UsersList = require 'modules/users/views/users_list'
GroupsList = require './groups_list'
GroupCreationForm = require './group_creation_form'

module.exports = Marionette.LayoutView.extend
  template: require './templates/network_layout'
  id: 'networkLayout'

  regions:
    friendsList: '#friendsList'
    groupList: '#groupsList'
    groupCreation: '#groupCreation'

  onShow: ->
    @showFriendsList()
    @showGroupCreationForm()

    app.request('waitForUserData').then @groupsList.bind(@)

  showFriendsList: ->
    @friendsList.show new UsersList
      collection: app.users.friends

  groupsList: ->
    @groupList.show new GroupsList
      collection: _.log app.user.groups, 'groups?'

  showGroupCreationForm: ->
    @groupCreation.show new GroupCreationForm
