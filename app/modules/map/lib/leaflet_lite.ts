// Set of functions borrowed from Leaflet to work on geographic positions
// when Leaflet itself has not be requested
// Source: https://github.com/Leaflet/Leaflet/blob/a1c1ea214f3077469ace7e9cef2d79225d757c97/src/geo/crs/CRS.Earth.js

const radius = 6371000

export default {
  distance (latlng1, latlng2) {
    const rad = Math.PI / 180
    const lat1 = latlng1.lat * rad
    const lat2 = latlng2.lat * rad
    const a = (Math.sin(lat1) * Math.sin(lat2)) +
      (Math.cos(lat1) * Math.cos(lat2) *
      Math.cos((latlng2.lng - latlng1.lng) * rad))

    return radius * Math.acos(Math.min(a, 1))
  }
}
