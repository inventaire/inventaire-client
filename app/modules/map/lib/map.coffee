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


module.exports =
  draw: (containerId, lat, lng, zoom=13)->
    latLngTupple = [lat, lng]
    map = L.map(containerId).setView latLngTupple, zoom
    L.tileLayer(tileUrl, settings).addTo map
    marker = L.marker(latLngTupple).addTo map
    marker.bindPopup("<b>Hello world!</b><br>I am a popup.")

    map.on 'moveend', updateRoute


    popup = L.popup()
        .setLatLng(latLngTupple)
        .setContent("I am a standalone popup.")
        .openOn(map)

    topleft = [Math.floor(lat*10)/10, Math.floor(lng*10)/10]
    topright = [Math.floor(lat*10)/10, Math.ceil(lng*10)/10]
    bottomright = [Math.ceil(lat*10)/10, Math.ceil(lng*10)/10]
    bottomleft = [Math.ceil(lat*10)/10, Math.floor(lng*10)/10]

    polygon = L.polygon([topleft, topright, bottomright, bottomleft]).addTo(map)

    return map

  getCurrentPosition: ->
    navigator.geolocation.getCurrentPosition (position)->
      _.log position, 'position'
      # position.coords.latitude, position.coords.longitude

updateRoute = (e)->
  { lat, lng } = e.target.getCenter()
  { _zoom } = e.target
  app.execute 'navigate:map', lat, lng, _zoom
