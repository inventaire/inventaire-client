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
    @showFriends(stretch)

  showFriends: (stretch=false)->
    @usersList.show new UsersList
      collection: app.users.filtered.friends()
      stretch: stretch

    @setFriendsHeader()

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

  resetSearch: ->
    @searchUsers ''
    @ui.userField.val ''

  callToActionIfFriendsListIsEmpty: ->
    if app.users.friends.length is 0
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