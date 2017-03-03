GroupsList = require './groups_list'
updateRoute = require('../lib/update_query_route')('groups', 'searchGroups')

module.exports = Marionette.LayoutView.extend
  template: require './templates/groups_search_layout'
  id: 'groupsSearchLayout'

  regions:
    'groupsList': '#groupsList'

  ui:
    groupSearch: '#groupSearch'

  events:
    'keyup #groupSearch': 'searchGroupFromEvent'

  initialize: ->
    { q } = @options.query
    @lastSearch = q or ''

    # groups waitForUserData to be initialized
    # so app.groups will be undefined before
    app.request 'wait:for', 'user'
    .then @initSearch.bind(@, q)

  initSearch: (q)->
    @collection = app.groups.filtered.resetFilters()
    app.execute 'fetch:last:groups:created'
    if _.isNonEmptyString q then @searchGroup q

  serializeData: ->
    groupsSearch:
      id: 'groupSearch'
      placeholder: 'search a group'
      value: @lastSearch

  onShow: ->
    app.request 'waitForNetwork'
    .then @showGroupList.bind(@)

  showGroupList: ->
    @groupsList.show new GroupsList
      collection: @collection
      mode: 'preview'
      emptyViewMessage: 'no group found with this name'

    # start with .noGroup hidden
    # will eventually be re-shown by empty results later
    $('.noGroup').hide()

  searchGroupFromEvent: ->
    @searchGroup @ui.groupSearch.val()

  searchGroup: (text)->
    updateRoute text
    @lastSearch = text
    @collection.searchByText text
