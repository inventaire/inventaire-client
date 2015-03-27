UserProfile = require './user_profile'

module.exports = Backbone.Marionette.LayoutView.extend
  id: 'innerNav'
  template: require './templates/side_nav'

  regions:
    one: '#one'
    usersList: '#usersList'

  ui:
    usersListHeader: "#usersListHeader"
    listToggler: ".listToggler"
    usersList: "#usersList"
    userField: "#userField"

  initialize: ->
    app.commands.setHandlers
      'sidenav:show:user': @showUser.bind(@)

    @lazyUserSearch = _.debounce @updateUserSearch, 100

  events:
    'keyup #userField': 'lazyUserSearch'
    'click a.close': 'resetSearch'
    'click #usersListHeader': 'toggleUsersList'

  onShow: ->
    @showFriends()

  showUser: (userModel)->
    @one.show new UserProfile {model: userModel}

  showFriends: ->
    collection = app.users.filtered.friends()
    @usersList.show new app.View.Users.List {collection: collection}
    @setFriendsHeader()

  updateUserSearch: (e)-> @searchUsers e.target.value

  searchUsers: (query)->
    app.request 'users:search', query
    if query? and query isnt ''
      @setUserSearchHeader()
    else @setFriendsHeader()

  setFriendsHeader: ->
    @ui.usersListHeader.find('.header').text _.i18n('friends list')
    @ui.usersListHeader.find('.close').hide()
    @callToActionIfFriendsListIsEmpty()

  setUserSearchHeader: ->
    @ui.usersListHeader.find('.header').text _.i18n('user search')
    @ui.usersListHeader.find('.close').show()

  callToActionIfFriendsListIsEmpty: ->
    if app.users.friends.length is 0
      # 'display' settings modified here will be overriden by no_user view re-rendering
      # in case of search thus the possibility to just handle changes in this direction
      $('.noUser').hide()
      $('.findFriends').show()

  resetSearch: ->
    @searchUsers('')
    @ui.userField.val('')

  toggleUsersList: ->
    if _.smallScreen()
      @ui.usersList.slideToggle()
      @ui.listToggler.toggle()
      @ui.userField.toggle()