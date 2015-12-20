map_ = require 'modules/map/lib/map'
{ showUsersOnMap, updateRouteFromEvent, pointInMap, BoundFilter } = map_
{ path } = require('../lib/network_tabs').tabsData.users.nearbyUsers
UsersList = require 'modules/users/views/users_list'
{ initMap } = require '../lib/nearby_layouts'

module.exports = Marionette.LayoutView.extend
  template: require './templates/nearby_users_layout'
  id: 'nearbyUsersLayout'

  regions:
    list: '#list'

  behaviors:
    PreventDefault: {}

  events:
    'click #showPositionPicker': -> app.execute 'show:position:picker'
    'click .userIcon a': 'showUserInventory'

  initialize: ->
    @collection = app.users.filtered.resetFilters()
    @listenTo app.user, 'change:position', @render.bind(@)
    @lazyInitMap = _.debounce @initMap.bind(@), 300

  onRender: ->
    app.request 'waitForData'
    # render might be called several times
    .then @lazyInitMap.bind(@)

  serializeData: ->
    hasPosition: app.user.hasPosition()

  initMap: ->
    initMap
      query: @options.query
      path: path
      showObjects: @showUsersNearby.bind(@)
      onMoveend: @onMovend.bind(@)
    .then @grabMap.bind(@)
    .then @initList.bind(@)
    .catch _.Error('initMap')

  grabMap: (map)->
    _.type map, 'object'
    @map = map

  onMovend: ->
    @refreshListFilter()
    @updateUsersMarkers()

  showUsersNearby: (map, latLng)->
    showUsersOnMap map, app.user

    app.request 'users:search:byPosition', latLng
    .then @updateUsersMarkers.bind(@)

  updateUsersMarkers: ->
    showUsersOnMap @map, @collection.models

  showUserInventory: (e)->
    unless _.isOpenedOutside e
      username = e.currentTarget.href.split('/').last()
      app.execute 'show:inventory:user', username

  initList: ->
    @list.show new UsersList
      collection: @collection
      stretch: true
      emptyViewMessage: "can't find any user at this location"

    @refreshListFilter()

  refreshListFilter: ->
    @collection.filterBy 'geobox', BoundFilter(@map)
