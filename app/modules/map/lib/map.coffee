{ defaultZoom } = require './config'

module.exports = map_ =
  draw: require './draw'
  getCurrentPosition: ->
    navigatorCurrentPosition()
    .then _.Log('current position')
    .then normalizeNavigatorCoords

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

  BoundFilter: (map)->
    bounds = map.getBounds()
    return filter = (model)->
      unless model.hasPosition() then return false
      point = model.getLatLng()
      return bounds.contains point

showUserOnMap = (map, user)->
  if user.hasPosition()
    map.addMarker
      objectId: user.cid
      model: user
      markerType: 'user'

# doc: https://developer.mozilla.org/en-US/docs/Web/API/Geolocation/getCurrentPosition
navigatorCurrentPosition = ->
  new Promise (resolve, reject)->
    unless navigator.geolocation?.getCurrentPosition?
      err = new Error 'getCurrentPosition isnt accessible'
      return reject err

    navigator.geolocation.getCurrentPosition resolve, reject,
      timeout: 20*1000

normalizeNavigatorCoords = (position)->
  { latitude, longitude } = position.coords
  return { lat: latitude, lng: longitude }
