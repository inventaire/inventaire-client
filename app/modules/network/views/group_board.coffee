groupPlugin = require '../plugins/group'
UsersList = require 'modules/users/views/users_list'

module.exports = Marionette.LayoutView.extend
  template: require './templates/group_board'
  className: 'groupBoard'
  initialize: ->
    @initPlugin()
    @collection = @model.users
    @mainUserStatus = @model.mainUserStatus()

  initPlugin: ->
    groupPlugin.call @

  behaviors:
    PreventDefault: {}

  regions:
    members: '.members'
    invite: '.invite'

  ui:
    body: '.body'
    caret: '.fa-caret-right'

  serializeData:->
    attrs = @model.serializeData()
    attrs.invitor = @invitorData()
    attrs["mainUser_#{@mainUserStatus}"] = true
    return attrs

  invitorData: ->
    username = @model.findMainUserInvitor()?.get('username')
    return {username: username}

  events:
    'click .toggler': 'toggleGroup'
    'click .joinRequest': 'requestToJoin'

  toggleGroup: ->
    @ui.body.slideToggle()
    @ui.caret.toggleClass 'toggled'

  onShow: ->
    @showMembers()
    if @mainUserStatus is 'member'
      @showFriendsInvitor()

  showMembers: ->
    @members.show @getGroupMembersListView()

  showFriendsInvitor: ->
    @invite.show @getFriendsInvitorView()
