{ tileUrl, settings, defaultZoom } = require './config'
buildMarker = require './build_marker'

module.exports = (params)->
  { containerId, latLng, zoom, bounds, cluster } = params
  zoom or= defaultZoom

  if latLng?
    map = L.map(containerId).setView(latLng, zoom)
  else
    map = L.map(containerId).fitBounds bounds

  L.tileLayer(tileUrl, settings).addTo map

  if _.isMobile then map.scrollWheelZoom.disable()

  if cluster then initWithCluster map
  else initWithoutCluster map

  return map

initWithCluster = (map)->
  cluster = L.markerClusterGroup()
  cluster._knownObjectIds = {}
  map.addLayer cluster
  map.addMarker = AddMarkerToCluster cluster
  return

initWithoutCluster = (map)->
  map.addMarker = AddMarkerToMap map
  return

AddMarkerToMap = (map)->
  addMarkerToMap = (params)->
    marker = buildMarker params
    marker.addTo map
    return marker

AddMarkerToCluster = (cluster)->
  addMarkerToCluster = (params)->
    { objectId } = params

    if cluster._knownObjectIds[objectId]
      _.log objectId, 'not re-adding known object'
      return

    marker = buildMarker params
    cluster.addLayer marker

    cluster._knownObjectIds[objectId] = true
    _.log objectId, 'added unknown object'

    return marker
