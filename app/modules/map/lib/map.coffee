accessToken = "pk.eyJ1IjoibWF4bGF0aGEiLCJhIjoiY2lldm9xdjFrMDBkMnN6a3NmY211MzQxcyJ9.a7_CBy6Xao-yF6f1cjsBNA"
tileUrl = "https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token=#{accessToken}"
settings =
  attribution: """
    Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors,
    <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>,
    Imagery © <a href="http://mapbox.com">Mapbox</a>"""
  maxZoom: 18
  id: 'maxlatha.gd5jof9d'
  accessToken: accessToken

L.Icon.Default.imagePath = '/public/images/map'

defaultZoom = 13

module.exports =
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

  updateRoute: (map, lat, lng, zoom=defaultZoom)->
    app.execute 'navigate:map', lat, lng, zoom

  updateMarker: (marker, lat, lng)->
    marker.setLatLng [lat, lng]

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
