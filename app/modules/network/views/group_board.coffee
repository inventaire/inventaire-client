groupPlugin = require '../plugins/group'
UsersList = require 'modules/users/views/users_list'

module.exports = Marionette.LayoutView.extend
  template: require './templates/group_board'
  className: 'groupBoard'
  initialize: ->
    @initPlugin()
    @collection = @model.members
    @mainUserStatus = @model.mainUserStatus()

  initPlugin: ->
    groupPlugin.call @

  behaviors:
    PreventDefault: {}

  regions:
    members: '.members > .users'
    invite: '.invite > .users'
    requests: '.requests > .users'

  ui:
    body: '.body'
    caret: '.fa-caret-right'
    requests: '.requests'

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
    if @mainUserStatus is 'member' then @showFriendsInvitor()
    if @model.requested.length > 0
      if @model.mainUserIsAdmin() then @showJoinRequests()
    else
      @ui.requests.hide()


    @toggleGroup()

  showMembers: ->
    @members.show @getGroupMembersListView()

  showFriendsInvitor: ->
    @invite.show @getFriendsInvitorView()

  showJoinRequests: ->
    @requests.show @getJoinRequestsView()