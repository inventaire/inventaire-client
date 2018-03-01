UsersList = require 'modules/users/views/users_list'

# required to be defined on the view:
# partials:
#  users_search
#  users_search_input

regions =
  usersList: '#usersList'

ui =
  usersListHeader: '#usersListHeader'
  userSearch: '#userSearch'
  userField: '#userField'

events =
  'keyup #userField': 'lazyUserSearch'
  'click a.close': 'resetSearch'

handlers =
  showUsersSearchBase: (stretch)->
    @ui.userSearch.show()
    @showFriends stretch

  showFriends: (stretch = false)->
    app.request 'fetch:friends'
    .then =>
      @usersList.show new UsersList
        # Passing the global users collection so that searchUsers
        # can add its users directly in the current collection
        collection: app.users.filtered.friends()
        stretch: stretch
        emptyViewMessage: "you aren't connected to anyone yet"
      @setFriendsHeader()

  updateUserSearch: (e)-> @searchUsers e.target.value

  searchUsers: (query)->
    if query isnt @lastQuery
      @lastQuery = query
      app.request 'users:search', query
      if query? and query isnt ''
        @setUserSearchHeader()
      else
        @setFriendsHeader()

  setFriendsHeader: ->
    @ui.usersListHeader.find('.header').text _.i18n('friends')
    @ui.usersListHeader.find('.close').hide()
    # Let a moment for the everything to come in place
    setTimeout @callToActionIfFriendsListIsEmpty.bind(@), 100

  setUserSearchHeader: ->
    @ui.usersListHeader.find('.header').text _.i18n('user search')
    @ui.usersListHeader.find('.close').show()

  resetSearch: ->
    @searchUsers ''
    @ui.userField.val ''

  callToActionIfFriendsListIsEmpty: (friends)->
    if app.relations.friends.length is 0
      # 'display' settings modified here will be overriden by no_user
      # view re-rendering in case of search thus the possibility
      # to just handle changes in this direction
      $('.noUser').hide()
      $('.findFriends').show()

module.exports = ->
  @lastQuery = null
  _.extend @, handlers
  @lazyUserSearch = _.debounce @updateUserSearch.bind(@), 100

  @addRegions regions
  _.extend (@events or= {}), events
  _.extend (@ui or= {}), ui
  return
