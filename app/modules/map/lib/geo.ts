import assert_ from '#app/lib/assert_types'
import leafletLite from './leaflet_lite.ts'

// Coordinates are returned in decimal degrees
// There is no need to keep more than 4 decimals, cf https://xkcd.com/2170/
// See https://developer.mozilla.org/en-US/docs/Web/API/GeolocationCoordinates
export function truncateDecimals (degree) {
  return Math.round(degree * 10000) / 10000
}

// a, b MUST be { lat, lng } coords objects
export function distanceBetween (a, b) {
  assert_.objects(arguments)
  // return the distance in kilometers
  return leafletLite.distance(a, b) / 1000
}
