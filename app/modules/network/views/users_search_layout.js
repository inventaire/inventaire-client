UsersList = require 'modules/users/views/users_list'
{ startLoading } = require 'modules/general/plugins/behaviors'

module.exports = Marionette.LayoutView.extend
  id: 'usersSearchLayout'
  template: require './templates/users_search_layout'
  regions:
    usersList: '#usersList'

  behaviors:
    Loading: {}

  events:
    'keyup #usersSearch': 'searchUserFromEvent'

  initialize: ->
    @collection = app.users.filtered.resetFilters()
    @initSearch()

  serializeData: ->
    usersSearch:
      id: 'usersSearch'
      placeholder: 'search for users'
      value: @lastQuery

  onShow: ->
    @lastQuery = ''
    @usersList.show new UsersList {
      @collection,
      groupContext: @options.groupContext,
      group: @options.group
      emptyViewMessage: @options.emptyViewMessage
      filter: @options.filter
    }

    # start with .noUser hidden
    # will eventually be re-shown by empty results later
    $('.noUser').hide()

  onRender: ->
    startLoading.call @, '#usersList'

  initSearch: ->
    q = @options.query?.q
    if _.isNonEmptyString q then @searchUser q

  searchUserFromEvent: (e)->
    query = e.target.value
    @searchUser query

  searchUser: (query)->
    @lastQuery = query
    app.request 'users:search', query
