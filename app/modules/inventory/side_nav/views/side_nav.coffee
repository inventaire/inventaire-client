UserLi = require 'modules/users/views/user_li'
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
    membersList: '#membersList'
    mainUser: '#mainUser'

  ui:
    two: '#two'

    listHeaders: '.listHeader'

    friendsSection: 'section#friends'
    usersList: '#usersList'
    usersToggler: '#usersListHeader .listToggler'

    groupsSection: 'section#groups'
    groupsList: '#groupsList'
    groupsToggler: '#groups .listToggler'

    membersSection: 'section#members'
    membersList: '#membersList'
    membersToggler: '#members .listToggler'
    memberSearch: '#memberSearch'

    loader: '.loader'
    togglers: '.toggler'

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
    'click .listHeader': 'toggleListHeader'

  serializeData: ->
    smallScreen: _.smallScreen()

  showBase: ->
    @_listReady = false
    @_usersListShown = false
    @_groupsListShown = false

    @showMainUser()

    @ui.two.show()
    @ui.membersSection.hide()
    @ui.memberSearch.hide()
    @ui.groupsSection.show()
    @ui.friendsSection.show()

    if _.smallScreen()
      app.request 'waitForUserData'
      .then @initBaseSmallScreen.bind(@)

    else
      @showUsersList()
      app.request 'waitForUserData'
      .then @showGroupsList.bind(@)
      # useful in case the screen is resized
      .then @initBaseSmallScreen.bind(@)

  initBaseSmallScreen: ->
    @_listReady = true
    @ui.loader.hide()
    @ui.togglers.show()

  showUser: (userModel)->
    @ui.two.hide()
    @one.show new UserProfile {model: userModel}

  showMainUser: ->
    @mainUser.show new UserLi {model: app.user}

  showUsersList: ->
    @_usersListShown = true
    @ui.friendsSection.show()
    @showUsersSearchBase()

  showGroupsList: ->
    @_groupsListShown = true
    @ui.groupsSection.show()
    @groupsList.show new GroupsList
      collection: app.user.groups.mainUserMember

  showGroup: (groupModel)->
    @_membersListShown = false
    @_currentGroup = groupModel
    if _.smallScreen()
      @one.show new Group
        model: groupModel
        highlighted: true
    else
      # shown by inventory::prepareGroupItemsList
      @showMembersList()
      @ui.userSearch.hide()
      @ui.memberSearch.show()


    @ui.groupsSection.hide()
    @ui.friendsSection.hide()
    @ui.membersSection.show()

    @setGroupHeader groupModel
    @initBaseSmallScreen()


  showMembersList: ->
    @_membersListShown = true
    @membersList.show new UsersList
      collection: @_currentGroup.members
      textFilter: true
      emptyViewMessage: "can't find any group member with that name"

  updateMemberFilter: (e)->
    text = e.currentTarget.value
    @membersList.currentView.trigger 'filter:text', text

  setGroupHeader: (group)->
    @ui.usersListHeader.find('.header').text _.i18n('group members')

  # used for smallScreens only
  toggleListHeader: (e)->
    # checking @_listReady as we don't want the toggler to be toggled
    # before lists are ready as it would be out of sync
    if @_listReady and _.smallScreen()
      { id } = e.currentTarget

      switch id
        when 'usersListHeader'
          # toggleUserSearch need to be before toggleList as will alter @_usersListShown
          @toggleUserSearch()
          @toggleList 'users', @_usersListShown

        when 'groupsListHeader'
          @toggleList 'groups', @_groupsListShown

        when 'membersListHeader'
          @toggleList 'members', @_membersListShown
          @ui.memberSearch.toggle()

  toggleList: (name, shown)->
    if shown
      @ui["#{name}List"].slideToggle 200
      @ui["#{name}Toggler"].toggle()
    else
      # showing the view will override display:none rules
      # we just miss the slide effect then
      @showList name
      @ui["#{name}Toggler"].toggle()

  showList: (name)->
    switch name
      when 'users' then @showUsersList()
      when 'groups' then @showGroupsList()
      when 'members' then @showMembersList()

  toggleUserSearch: ->
    if @_usersListShown then @ui.userSearch.toggle()
    else @ui.userSearch.show()
