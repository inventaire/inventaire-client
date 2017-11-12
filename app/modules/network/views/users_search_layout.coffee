UsersList = require 'modules/users/views/users_list'
behaviorsPlugin = require 'modules/general/plugins/behaviors'
updateRoute = require('../lib/update_query_route')('users', 'searchUsers')

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
    { @stretch, @updateRoute } = @options
    @stretch ?= true
    @updateRoute ?= true

  serializeData: ->
    usersSearch:
      id: 'usersSearch'
      placeholder: 'search for users'
      value: @lastQuery

  onShow: ->
    @lastQuery = ''
    @usersList.show new UsersList {
      @collection,
      @stretch,
      groupContext: @options.groupContext,
      group: @options.group
      emptyViewMessage: @options.emptyViewMessage
      filter: @options.filter
    }

    # start with .noUser hidden
    # will eventually be re-shown by empty results later
    $('.noUser').hide()

  onRender: ->
    behaviorsPlugin.startLoading.call @, '#usersList'

  initSearch: ->
    q = @options.query?.q
    if _.isNonEmptyString q then @searchUser q

  searchUserFromEvent: (e)->
    query = e.target.value
    if @updateRoute then updateRoute query
    @searchUser query

  searchUser: (query)->
    @lastQuery = query
    app.request 'users:search', query
