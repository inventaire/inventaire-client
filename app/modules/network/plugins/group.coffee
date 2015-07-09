UsersList = require 'modules/users/views/users_list'

events =
  'click .showGroup': 'showGroup'

handlers =
  showGroup: (e)->
    unless _.isOpenedOutside e
      app.execute 'show:inventory:group', @model

  getGroupMembersListView: ->
    new UsersList
      collection: @model.users

  getFriendsInvitorView: ->
    new UsersList
      collection: app.users.friends
      groupContext: true
      group: @model
      emptyViewMessage: 'no friends to invite'
      filter: (child, index, collection)->
        # in the context of the usersList view
        @options.group.userStatus(child) isnt 'member'

module.exports = _.BasicPlugin events, handlers
