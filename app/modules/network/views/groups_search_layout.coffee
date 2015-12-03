GroupsList = require './groups_list'

module.exports = Marionette.LayoutView.extend
  template: require './templates/groups_search_layout'
  id: 'groupsSearchLayout'

  initialize: ->
    @lastSearch = ''

  regions:
    'groupsList': '#groupsList'

  ui:
    groupSearch: '#groupSearch'

  serializeData: ->
    groupsSearch:
      id: 'groupSearch'
      placeholder: 'search a group'

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

    # start with no group hidden
    # will eventually be re-shown by empty results later
    $('.noGroup').hide()

  groupSearch: ->
    text = @ui.groupSearch.val()
    unless text is @lastSearch
      @lastSearch = text
      @collection.searchByText text

  events:
    'keyup #groupSearch': 'groupSearch'
