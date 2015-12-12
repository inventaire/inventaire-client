GroupsList = require './groups_list'
updateRoute = require('../lib/update_query_route')('searchGroups')

module.exports = Marionette.LayoutView.extend
  template: require './templates/groups_search_layout'
  id: 'groupsSearchLayout'

  initialize: ->
    @initSearch()

  regions:
    'groupsList': '#groupsList'

  ui:
    groupSearch: '#groupSearch'

  events:
    'keyup #groupSearch': 'searchGroupFromEvent'

  serializeData: ->
    groupsSearch:
      id: 'groupSearch'
      placeholder: 'search a group'
      value: @lastSearch

  onShow: ->
    app.request 'waitForData'
    .then @showGroupList.bind(@)

  showGroupList: ->
    app.execute 'fetch:last:group:created'
    @collection = app.user.groups.filtered.resetFilters()

    @groupsList.show new GroupsList
      collection: @collection
      mode: 'preview'
      emptyViewMessage: 'no group found with this name'

    # start with .noGroup hidden
    # will eventually be re-shown by empty results later
    $('.noGroup').hide()

  initSearch: ->
    { q } = @options.query
    @lastSearch = q or ''
    if _.isNonEmptyString q then @searchGroup q

  searchGroupFromEvent: ->
    @searchGroup @ui.groupSearch.val()

  searchGroup: (text)->
    updateRoute text
    if text is ''
      @collection.resetFilters()
      return

    unless text is @lastSearch
      @lastSearch = text
      @collection.searchByText text
