map_ = require 'modules/map/lib/map'
{ showUsersOnMap, updateRoute, updateRouteFromEvent, pointInMap, BoundFilter } = map_
{ path } = require('../lib/network_tabs').tabsData.users.nearbyUsers
UsersList = require 'modules/users/views/users_list'

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

  onRender: ->
    app.request 'waitForData'
    .then @initMap.bind(@)
    .then @initList.bind(@)

  serializeData: ->
    hasPosition: app.user.hasPosition()

  initMap: ->
    @findPosition()
    .then @_initMap.bind(@)
    .catch (err)->
      msg = "Map container is already initialized."
      # Error happening when the map is initialized several times
      # (maybe due to a promise triggering its callback several times?)
      # Leaflet just doesn't take the extra ones
      if err.message is msg then _.warn msg
      else throw err

  _initMap: (coords)->
    { lat, lng, zoom } = coords
    @map = map = map_.draw 'map', lat, lng, zoom

    # update the path after the tabs lazyrendered and updated the path
    fn = updateRoute.bind null, path, lat, lng, zoom
    setTimeout fn, 500

    # marker = map_.addCircleMarker map, lat, lng

    @showUsersNearby map, [lat, lng]

    map.on 'moveend', updateRouteFromEvent.bind(null, path)
    map.on 'moveend', @refreshListFilter.bind(@)
    map.on 'moveend', @updateUsersMarkers.bind(@)

  findPosition: ->
    # priority is given to passed parameters
    { lat, lng, zoom } = @options.query
    if lat? and lng? then return _.preq.resolve @options.query

    # then to the user saved position
    { user } = app
    if user.hasPosition() then return _.preq.resolve user.getPosition()

    # finally a request for the user position is issued
    return map_.getCurrentPosition()

  showUsersNearby: (map, latLng)->
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
