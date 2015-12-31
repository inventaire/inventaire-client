map_ = require '../lib/map'
{ updateRoute, updateRouteFromEvent } = map_
userMarker = require './templates/user_marker'
Items = require 'modules/inventory/collections/items'
ItemsList = require 'modules/inventory/views/items_list'

module.exports = Marionette.LayoutView.extend
  template: require './templates/map_layout'
  id: 'mapLayout'
  regions:
    list: '#list'

  behaviors:
    PreventDefault: {}

  events:
    'click #showPositionPicker': -> app.execute 'show:position:picker:main:user'
    'click .userIcon a': 'showUserInventory'

  initialize: ->
    @listenTo app.user, 'change:position', @render.bind(@)

  onRender: ->
    if app.user.hasPosition() then @initMap()

  serializeData: ->
    hasPosition: app.user.hasPosition()

  initMap: ->
    @findPosition()
    .then @_initMap.bind(@)
    .catch _.Error('initMap err')

  _initMap: (coords)->
    { lat, lng, zoom } = coords
    map = map_.draw
      containerId: 'map'
      latLng: [lat, lng]
      zoom: zoom
      cluster: true

    updateRoute 'map', lat, lng, zoom

    @showUsersNearby map, [lat, lng]

    map.on 'moveend', updateRouteFromEvent.bind(null, 'map')

  findPosition: ->
    # priority is given to passed parameters
    { lat, lng, zoom } = @options.coordinates
    if lat? and lng? then return _.preq.resolve @options.coordinates

    # then to the user saved position
    { user } = app
    if user.hasPosition() then return _.preq.resolve user.getPosition()

    # finally a request for the user position is issued
    return map_.getCurrentPosition()

  showUsersNearby: (map, latLng)->
    app.request 'users:search:byPosition', latLng
    .then (usersCollection)=>
      @showUsersOnMap map, usersCollection
      @showUsersItems usersCollection

  showUsersOnMap: (map, collection)->
    for user in collection.models
      showUserOnMap map, user

    showUserOnMap map, app.user

  showUsersItems: (usersCollection)->
    usersIds = usersCollection.map _.property('id')
    app.request 'inventory:fetch:users:public:items', usersIds
    .then _.Log('ITEMS')
    .then @showItemsList.bind(@)

  showItemsList: (items)->
    @list.show new ItemsList
      collection: new Items items

  showUserInventory: (e)->
    unless _.isOpenedOutside e
      username = e.currentTarget.href.split('/').last()
      app.execute 'show:inventory:user', username

showUserOnMap = (map, user)->
  if user.hasPosition()
    map.addMarker
      markerType: 'user'
      model: user
