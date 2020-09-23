{ tileUrl, settings, defaultZoom } = require './config'
buildMarker = require './build_marker'

module.exports = (params)->
  { containerId, latLng, zoom, bounds, cluster } = params
  bounds = _.compact bounds

  if bounds.length is 1
    latLng = bounds[0]
    zoom = 5

  zoom or= defaultZoom

  map = L.map containerId

  if latLng? then map.setView latLng, zoom
  else map.fitBounds bounds

  L.tileLayer(tileUrl, settings).addTo map

  if _.isMobile then map.scrollWheelZoom.disable()

  if cluster then initWithCluster map
  else initWithoutCluster map

  return map

initWithCluster = (map)->
  # See options https://github.com/Leaflet/Leaflet.markercluster#options
  cluster = L.markerClusterGroup()
  cluster._knownObjectIds = {}
  map.addLayer cluster
  map.addMarker = addMarkerToCluster cluster
  return

initWithoutCluster = (map)->
  map.addMarker = addMarkerToMap map
  return

addMarkerToMap = (map)-> (params)->
  marker = buildMarker params
  marker.addTo map
  return marker

addMarkerToCluster = (cluster)-> (params)->
  { objectId } = params

  if cluster._knownObjectIds[objectId]
    _.log objectId, 'not re-adding known object'
    return

  marker = buildMarker params
  cluster.addLayer marker

  cluster._knownObjectIds[objectId] = true
  _.log objectId, 'added unknown object'

  return marker
