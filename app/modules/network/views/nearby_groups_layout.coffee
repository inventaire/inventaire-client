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
    Loading: {}

  events:
    'click .groupMarker a': 'showGroup'

  initMap: ->
    @collection or= app.groups.filtered.resetFilters()
    initMap
      view: @
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
    .then @ifViewIsIntact('lazyInitMap')

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
      id = e.currentTarget.attributes['data-group-id'].value
      app.execute 'show:inventory:group:byId', { groupId: id }

  initList: ->
    @list.show new GroupsList
      collection: @collection
      mode: 'preview'
      emptyViewMessage: "can't find any group at this location"

    refreshListFilter.call @
