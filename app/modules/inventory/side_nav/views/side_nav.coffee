UserProfile = require './user_profile'

module.exports = class SideNav extends Backbone.Marionette.LayoutView
  id: 'innerNav'
  template: require './templates/side_nav'

  regions:
    one: '#one'
    userList: '#userList'

  ui:
    userListHeader: "#userListHeader"
    userField: "#userField"

  initialize: ->
    app.commands.setHandlers
      'sidenav:show:user': @showUser.bind(@)

    @lazyUserSearch = _.debounce @updateUserSearch, 100

  events:
    'keyup #userField': 'lazyUserSearch'
    'click a.close': 'resetSearch'

  onShow: ->
    @showFriends()

  showUser: (userModel)->
    @one.show new UserProfile {model: userModel}

  showFriends: ->
    collection = app.users.filtered.friends()
    @userList.show new app.View.Users.List {collection: collection}
    @setFriendsHeader()

  updateUserSearch: (e)-> @searchUsers e.target.value

  searchUsers: (query)->
    app.request 'users:search', query
    if query? and query isnt ''
      @setUserSearchHeader()
    else @setFriendsHeader()

  setFriendsHeader: ->
    @ui.userListHeader.find('.header').text _.i18n('Friends list')
    @ui.userListHeader.find('.close').hide()

  setUserSearchHeader: ->
    @ui.userListHeader.find('.header').text _.i18n('User search')
    @ui.userListHeader.find('.close').show()

  resetSearch: ->
    @searchUsers('')
    @ui.userField.val('')