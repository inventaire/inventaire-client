{ initMap, regions, grabMap, refreshListFilter } = require '../lib/nearby_layouts'
{ showGroupsOnMap, getBbox } = require 'modules/map/lib/map'
{ path } = require('../lib/network_tabs').tabsData.groups.nearbyGroups
GroupsList = require './groups_list'

module.exports = Marionette.LayoutView.extend
  template: require './templates/nearby_layout'
  id: 'nearbyGroupsLayout'
  regions: regions
  behaviors:
    PreventDefault: {}

  events:
    'click .groupIcon a': 'showGroup'

  initMap: ->
    @collection or= app.groups.filtered.resetFilters()
    initMap
      query: @options.query
      path: path
      showObjects: @showGroupsNearby.bind(@)
      onMoveend: @onMovend.bind(@)
    .then grabMap.bind(@)
    .then @initList.bind(@)
    .catch _.Error('initMap')

  initialize: ->
    @lazyInitMap = _.debounce @initMap.bind(@), 300

  onRender: ->
    app.request 'waitForNetwork'
    # render might be called several times
    .then @lazyInitMap.bind(@)

  onMovend: ->
    refreshListFilter.call @
    @showGroupsNearby @map

  showGroupsNearby: (map)->
    @collection.searchByPosition getBbox(map)
    .then @updateGroupsMarkers.bind(@)

  updateGroupsMarkers: ->
    showGroupsOnMap @map, @collection.models

  showGroup: (e)->
    unless _.isOpenedOutside e
      id = e.currentTarget.href.split('/')[2]
      app.execute 'show:inventory:group', id

  initList: ->
    @list.show new GroupsList
      collection: @collection
      mode: 'preview'
      emptyViewMessage: "can't find any group at this location"

    refreshListFilter.call @
