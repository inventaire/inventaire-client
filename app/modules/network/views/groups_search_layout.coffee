GroupsList = require './groups_list'
updateRoute = require('../lib/update_query_route')('groups', 'searchGroups')
forms_ = require 'modules/general/lib/forms'
error_ = require 'lib/error'
Group = require '../models/group'
# Not using the ../collections/groups to avoid having a comparator
Groups = Backbone.Collection.extend { model: Group }

module.exports = Marionette.LayoutView.extend
  template: require './templates/groups_search_layout'
  id: 'groupsSearchLayout'

  behaviors:
    AlertBox: {}

  regions:
    'groupsList': '#groupsList'

  ui:
    groupSearch: '#groupSearch'

  events:
    'keyup #groupSearch': 'searchGroupFromEvent'

  initialize: ->
    { q } = @options.query
    @lastSearch = q?.trim() or ''
    @collection = new Groups
    @searchGroup @lastSearch

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
    @lazySearchByText text

  lazySearchByText: _.lazyMethod 'searchByText', 100
  searchByText: (text)->
    @_searchByText text
    .catch error_.Complete('#groupSearch', false)
    .catch forms_.catchAlert.bind(null, @)

  _searchByText: (text)->
    if _.isNonEmptyString text
      app.request 'groups:search', text
      .then @_updateCollection.bind(@)
    else
      app.request 'groups:last'
      .then @_updateCollection.bind(@)

  _updateCollection: (groupsData)->
    @collection.reset()
    @collection.add groupsData
    return
