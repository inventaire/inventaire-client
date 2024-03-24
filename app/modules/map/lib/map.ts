import mapConfig from './config.js'
import { truncateDecimals } from './geo.js'
import { buildPath } from '#lib/location'
import { compact, uniq } from 'underscore'

const { defaultZoom } = mapConfig

export function updateRoute (root, lat, lng, zoom = defaultZoom) {
  lat = truncateDecimals(lat)
  lng = truncateDecimals(lng)
  // Keep only defined parameters in the route
  // Allow to pass a custom root to let it be used in multiple modules
  const route = buildPath(root, { lat, lng, zoom })
  app.navigate(route, { preventScrollTop: true })
}

export function updateMarker (marker, coords) {
  if (coords?.lat == null) return marker.remove()
  const { lat, lng } = coords
  return marker.setLatLng([ lat, lng ])
}

export function getBbox (map) {
  const { _southWest, _northEast } = map.getBounds()
  if (_southWest.lng === _northEast.lng || _southWest.lat === _northEast.lat) {
    return
  }
  return [ _southWest.lng, _southWest.lat, _northEast.lng, _northEast.lat ]
}

export function uniqBounds (bounds) {
  const stringifiedBounds = compact(bounds).map(stringifyBound)
  return uniq(stringifiedBounds).map(parseStringifiedBound)
}

const stringifyBound = bound => JSON.stringify(bound)
const parseStringifiedBound = stringifiedBound => JSON.parse(stringifiedBound)
