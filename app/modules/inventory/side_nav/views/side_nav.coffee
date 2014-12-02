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
    @showFriends()

  showUser: (userModel)->
    @one.show new UserProfile {model: userModel}

  showFriends: ->
    collection = app.users.filtered.friends()
    @userList.show new app.View.Users.List {collection: collection}

  updateUserSearch: (e)->
    query = e.target.value
    app.request 'users:search', query
