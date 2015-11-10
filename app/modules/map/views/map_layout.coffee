map_ = require '../lib/map'
userMarker = require './templates/user_marker'
Items = require 'modules/inventory/collections/items'
ItemsList = require 'modules/inventory/views/items_list'

module.exports = Marionette.LayoutView.extend
  template: require './templates/map_layout'
  id: 'mapLayout'
  regions:
    list: '#list'

  events:
    'click #showPositionPicker': -> app.execute 'show:position:picker'

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
    map = map_.draw 'map', lat, lng, zoom

    map_.updateRoute map, lat, lng, zoom
    # marker = map_.addCircleMarker map, lat, lng

    @showUsersNearby map, [lat, lng]

    map.on 'moveend', updateRoute.bind(null, map)

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
    collection.forEach showUserOnMap.bind(null, map)
    showUserOnMap map, app.user

  showUsersItems: (usersCollection)->
    usersIds = usersCollection.map _.property('id')
    app.request 'inventory:fetch:users:public:items', usersIds
    .then _.Log('ITEMS')
    .then @showItemsList.bind(@)

  showItemsList: (items)->
    @list.show new ItemsList
      collection: new Items items

updateRoute = (map, e)->
  { lat, lng } = e.target.getCenter()
  { _zoom } = e.target
  map_.updateRoute map, lat, lng, _zoom

showUserOnMap = (map, user)->
  if user.hasPosition()
    { lat, lng } = user.getPosition()
    iconContent = userMarker(user.toJSON())
    map_.addCustomIconMarker map, lat, lng, iconContent
