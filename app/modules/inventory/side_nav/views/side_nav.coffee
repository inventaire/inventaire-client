UserProfile = require './user_profile'

module.exports = class SideNav extends Backbone.Marionette.LayoutView
  id: 'innerNav'
  template: require './templates/side_nav'

  regions:
    one: '#one'
    userList: '#userList'

  initialize: ->
    app.commands.setHandlers
      'sidenav:show:user': @showUser.bind(@)

    @lazyUserSearch = _.debounce @updateUserSearch, 100

  events:
    'keyup #userField': 'lazyUserSearch'

  onShow: ->
    @showUsers()

  showUser: (userModel)->
    @one.show new UserProfile {model: userModel}

  showUsers: ->
    @userList.show new app.View.Users.List {collection: app.users.filtered}

  updateUserSearch: (e)->
    query = e.target.value
    app.request 'users:search', query
