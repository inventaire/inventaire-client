UsersList = require 'modules/users/views/users_list'
behaviorsPlugin = require 'modules/general/plugins/behaviors'
{ path } = require('../lib/network_tabs').tabsData.users.searchUsers

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
    @usersList.show new UsersList
      collection: @collection
      stretch: true

  onRender: ->
    behaviorsPlugin.startLoading.call @, '#usersList'

  initSearch: ->
    { q } = @options.query
    if _.isNonEmptyString q then @searchUser q

  searchUserFromEvent: (e)->
    query = e.target.value
    lazyUpdateRoute query
    @searchUser query

  searchUser: (query)->
    @lastQuery = query
    app.request 'users:search', query

updateRoute = (query)->
  app.navigate _.buildPath(path, {q: query})

lazyUpdateRoute = _.debounce updateRoute, 300
