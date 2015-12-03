UsersList = require 'modules/users/views/users_list'
behaviorsPlugin = require 'modules/general/plugins/behaviors'
# UsersSearch = require 'modules/network/plugins/users_search'

module.exports = Marionette.LayoutView.extend
  id: 'usersSearch'
  template: require './templates/users_search_layout'
  regions:
    usersList: '#usersList'

  onShow: ->
    @usersList.show new UsersList
      collection: app.users.filtered.resetFilters()
      stretch: true

  behaviors:
    Loading: {}

  events:
    'keyup #userSearch': 'searchUser'

  serializeData: ->
    userSearch:
      id: 'userSearch'
      placeholder: 'search for users'

  onRender: ->
    behaviorsPlugin.startLoading.call @, '#usersList'

  searchUser: (e)->
    query = e.target.value
    app.request 'users:search', query
