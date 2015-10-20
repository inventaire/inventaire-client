map_ = require '../lib/map'
PositionPicker = require './position_picker'

module.exports = Marionette.LayoutView.extend
  template: require './templates/map_layout'
  id: 'mapLayout'
  onShow: ->
    @initMap()

  events:
    'click #showPositionPicker': 'showPositionPicker'

  initMap: ->
    @findPosition()
    .then @_initMap
    .catch _.Error('initMap err')

  _initMap: (coords)->
    { lat, lng, zoom } = coords
    map = map_.draw 'map', lat, lng, zoom

    map_.updateRoute map, lat, lng, zoom
    marker = map_.addCircleMarker map, lat, lng

    map.on 'moveend', updateRoute.bind(null, map)
    map.on 'move', updateMarker.bind(null, marker)

  findPosition: ->
    { lat, lng, zoom } = @options.coordinates
    if lat? and lng? then _.preq.resolve @options.coordinates
    else map_.getCurrentPosition()

  showPositionPicker: ->
    app.layout.modal.show new PositionPicker

updateRoute = (map, e)->
  { lat, lng } = e.target.getCenter()
  { _zoom } = e.target
  map_.updateRoute map, lat, lng, _zoom

updateMarker = (marker, e)->
  { lat, lng } = e.target.getCenter()
  map_.updateMarker marker, lat, lng
