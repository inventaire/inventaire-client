UsersList = require 'modules/users/views/users_list'
UserProfile = require './user_profile'
GroupsList = require 'modules/network/views/groups_list'
Group = require 'modules/network/views/group'
UsersSearch = require 'modules/network/plugins/users_search'

module.exports = Marionette.LayoutView.extend
  id: 'innerNav'
  template: require './templates/side_nav'

  regions:
    one: '#one'
    groupsList: '#groupsList'

  ui:
    two: '#two'
    listToggler: '.listToggler'
    usersList: '#usersList'
    groupsSection: 'section#groups'
    memberSearch: '#memberSearch'

  initialize: ->
    @initPlugins()
    app.commands.setHandlers
      'sidenav:show:base': @showBase.bind(@)
      'sidenav:show:user': @showUser.bind(@)
      'sidenav:show:group': @showGroup.bind(@)

    @lazyMemberFilter = _.debounce @updateMemberFilter, 100

  initPlugins: ->
    UsersSearch.call @

  events:
    'keyup #memberField': 'lazyMemberFilter'
    'click #usersListHeader': 'toggleUsersList'

  showBase: ->
    @ui.two.show()
    @ui.memberSearch.hide()
    @showUsersSearchBase()
    app.request('waitForUserData').then @showGroups.bind(@)

  showUser: (userModel)->
    @ui.two.hide()
    @one.show new UserProfile {model: userModel}

  showGroups: ->
    @ui.groupsSection.show()
    @groupsList.show new GroupsList
      collection: app.user.groups.mainUserMember

  showGroup: (groupModel)->
    @one.show new Group
      model: groupModel
      highlighted: true
    @ui.groupsSection.hide()
    @setGroupHeader groupModel
    @ui.userSearch.hide()
    @ui.memberSearch.show()
    @usersList.show new UsersList
      collection: groupModel.members
      textFilter: true
      emptyViewMessage: "can't find any group member with that name"

  updateMemberFilter: (e)->
    text = e.currentTarget.value
    @usersList.currentView.trigger 'filter:text', text

  setGroupHeader: (group)->
    @ui.usersListHeader.find('.header').text _.i18n('group members')

  toggleUsersList: ->
    if _.smallScreen()
      @ui.usersList.slideToggle()
      @ui.listToggler.toggle()
      @ui.userField.toggle()
