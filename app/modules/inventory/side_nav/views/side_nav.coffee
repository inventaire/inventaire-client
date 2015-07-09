UserProfile = require './user_profile'
GroupsList = require 'modules/network/views/groups_list'
Group = require 'modules/network/views/group'

module.exports = Marionette.LayoutView.extend
  id: 'innerNav'
  template: require './templates/side_nav'

  regions:
    one: '#one'
    groupsList: '#groupsList'
    usersList: '#usersList'

  ui:
    usersListHeader: '#usersListHeader'
    listToggler: '.listToggler'
    usersList: '#usersList'
    userField: '#userField'
    groupsSection: 'section#groups'

  initialize: ->
    @lastQuery = null
    app.commands.setHandlers
      'sidenav:show:base': @showBase.bind(@)
      'sidenav:show:user': @showUser.bind(@)
      'sidenav:show:group': @showGroup.bind(@)

    @lazyUserSearch = _.debounce @updateUserSearch, 100

  events:
    'keyup #userField': 'lazyUserSearch'
    'click a.close': 'resetSearch'
    'click #usersListHeader': 'toggleUsersList'

  showBase: ->
    @showFriends()
    app.request('waitForUserData').then @showGroups.bind(@)

  showUser: (userModel)->
    @showBase()
    @one.show new UserProfile {model: userModel}

  showGroups: ->
    @ui.groupsSection.show()
    @groupsList.show new GroupsList
      collection: app.user.groups.mainUserMember

  showFriends: ->
    collection = app.users.filtered.friends()
    @usersList.show new app.View.Users.List {collection: collection}
    @setFriendsHeader()

  showGroup: (groupModel)->
    @ui.groupsSection.hide()
    @usersList.show new app.View.Users.List {collection: groupModel.users}
    @setGroupHeader groupModel
    @one.show new Group
      model: groupModel
      highlighted: true

  updateUserSearch: (e)-> @searchUsers e.target.value

  searchUsers: (query)->
    if query isnt @lastQuery
      @lastQuery = query
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

  setGroupHeader: (group)->
    @ui.usersListHeader.find('.header').text _.i18n('group members')

  callToActionIfFriendsListIsEmpty: ->
    if app.users.friends.length is 0
      # 'display' settings modified here will be overriden by no_user view re-rendering
      # in case of search thus the possibility to just handle changes in this direction
      $('.noUser').hide()
      $('.findFriends').show()

  resetSearch: ->
    @searchUsers ''
    @ui.userField.val ''

  toggleUsersList: ->
    if _.smallScreen()
      @ui.usersList.slideToggle()
      @ui.listToggler.toggle()
      @ui.userField.toggle()