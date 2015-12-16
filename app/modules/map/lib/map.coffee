{ tileUrl, settings, defaultZoom } = require './config'
userMarker = require '../views/templates/user_marker'

module.exports = map_ =
  draw: (containerId, lat, lng, zoom=defaultZoom)->
    map = L.map(containerId).setView [lat, lng], zoom
    L.tileLayer(tileUrl, settings).addTo map

    return map

  getCurrentPosition: ->
    navigatorCurrentPosition()
    .then _.Log('current position')
    .then normalizeNavigatorCoords

  addMarker: (map, lat, lng, content, openPopup=false)->
    marker = L.marker([lat, lng]).addTo map
    marker.bindPopup content
    if openPopup then marker.openPopup()
    return marker

  addCircleMarker: (map, lat, lng, metersRadius=200)->
    marker = L.circle([lat, lng], metersRadius).addTo map
    return marker

  addCustomIconMarker: (map, lat, lng, html)->
    icon = customIcon html
    marker = L.marker([lat, lng], {icon: icon}).addTo map
    return marker

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
    { lat, lng } = user.getPosition()
    iconContent = userMarker user.toJSON()
    map_.addCustomIconMarker map, lat, lng, iconContent

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


customIcon = (html, className='')->
  L.divIcon
    className: "map-icon #{className}"
    html: html
