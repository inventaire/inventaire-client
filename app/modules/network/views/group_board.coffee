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
    requests: '#requests > .users'
    members: '#members > .users'
    invite: '#invite > .users'

  ui:
    requests: '#requests'

  serializeData:->
    attrs = @model.serializeData()
    attrs.invitor = @invitorData()
    attrs["mainUser_#{@mainUserStatus}"] = true
    return attrs

  invitorData: ->
    username = @model.findMainUserInvitor()?.get('username')
    return {username: username}

  events:
    'click .toggler': 'toggleSection'
    'click .joinRequest': 'requestToJoin'

  toggleSection: (e)->
    section = e.currentTarget.parentElement.attributes.id.value
    { $el } = @[section]
    $el.slideToggle()
    $el.parent().find('.fa-caret-down').toggleClass 'toggled'

  onShow: ->
    @showMembers()
    if @mainUserStatus is 'member' then @showFriendsInvitor()
    if @model.requested.length > 0 and @model.mainUserIsAdmin()
      @showJoinRequests()
    else
      @ui.requests.hide()

  showJoinRequests: ->
    @requests.show @getJoinRequestsView()

  showMembers: ->
    @members.show @getGroupMembersListView()

  showFriendsInvitor: ->
    @invite.show @getFriendsInvitorView()