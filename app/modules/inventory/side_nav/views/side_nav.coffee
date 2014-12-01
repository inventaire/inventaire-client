UserProfile = require './user_profile'

module.exports = class SideNav extends Backbone.Marionette.LayoutView
  id: 'innerNav'
  template: require './templates/side_nav'

  regions:
    one: '#one'
    two: '#two'
    three: '#three'

  initialize: ->
    app.commands.setHandlers
      'sidenav:show:user': @showUser.bind(@)

  onShow: ->
    @showUsers()

  showUser: (userModel)->
    @one.show new UserProfile {model: userModel}

  showUsers: ->
    @two.show new app.View.Users.List {collection: app.users.filtered}