{ defaultZoom } = require './config'
getCurrentPosition = require './navigator_position'

module.exports = map_ =
  draw: require './draw'
  getCurrentPosition: getCurrentPosition

  updateRoute: (root, lat, lng, zoom=defaultZoom)->
    # Keep only defined parameters in the route
    # Allow to pass a custom root to let it be used in multiple modules
    route = _.buildPath root, {lat: lat, lng: lng, zoom: zoom}
    app.navigate route

  updateRouteFromEvent: (root, e)->
    { lat, lng } = e.target.getCenter()
    { _zoom } = e.target
    map_.updateRoute root, lat, lng, _zoom

  updateMarker: (marker, lat, lng)->
    marker.setLatLng [lat, lng]

  showUsersOnMap: (map, users)->
    for user in _.forceArray users
      showUserOnMap map, user

  showGroupsOnMap: (map, groups)->
    for group in _.forceArray groups
      showGroupOnMap map, group

  BoundFilter: (map)->
    bounds = map.getBounds()
    return filter = (model)->
      unless model.hasPosition() then return false
      point = model.getLatLng()
      return bounds.contains point

  # a, b MUST be LatLng arrays
  distanceBetween: (a, b)->
    _.types arguments, 'arrays...'
    a = new L.LatLng a[0], a[1]
    b = new L.LatLng b[0], b[1]
    # return the distance in kilometers
    return a.distanceTo(b) / 1000

showUserOnMap = (map, user)->
  if user.hasPosition()
    map.addMarker
      objectId: user.cid
      model: user
      markerType: 'user'

showGroupOnMap = (map, group)->
  if group.hasPosition()
    map.addMarker
      objectId: group.cid
      model: group
      markerType: 'group'
