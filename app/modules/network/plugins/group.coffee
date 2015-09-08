UsersList = require 'modules/users/views/users_list'
behaviorsPlugin = require 'modules/general/plugins/behaviors'

events =
  'click .showGroup': 'showGroup'
  'click .accept': 'acceptInvitation'
  'click .decline': 'declineInvitation'
  'click .joinRequest': 'joinRequest'
  'click .cancelRequest': 'cancelRequest'

handlers =
  showGroup: (e)->
    unless _.isOpenedOutside e
      app.execute 'show:inventory:group', @model

  getGroupMembersListView: ->
    new UsersList
      collection: @model.members
      groupContext: true
      group: @model

  getFriendsInvitorView: ->
    group = @model
    new UsersList
      collection: app.users.friends
      groupContext: true
      group: group
      emptyViewMessage: 'no friends to invite'
      filter: (child, index, collection)->
        # in the context of the usersList view
        group.userStatus(child) isnt 'member'

  getJoinRequestsView: ->
    new UsersList
      collection: @model.requested
      groupContext: true
      group: @model
      emptyViewMessage: 'no more pending requests'

  acceptInvitation: -> @model.acceptInvitation()
  declineInvitation: -> @model.declineInvitation()
  joinRequest: ->
    id = @model.id
    name = @model.get 'name'
    if app.request 'require:loggedIn', "groups/#{id}/#{name}"
      @model.requestToJoin()
      .catch behaviorsPlugin.Fail.call(@, 'joinRequest')

  cancelRequest: ->
    @model.cancelRequest()
    .catch behaviorsPlugin.Fail.call(@, 'cancelRequest')

module.exports = _.BasicPlugin events, handlers
