import { compact, uniq } from 'underscore'
import app from '#app/app'
import { buildPath } from '#app/lib/location'
import type Marker from '#map/components/marker.svelte'
import type { BBox, LatLng } from '#server/types/common'
import mapConfig from './config.ts'
import { truncateDecimals } from './geo.ts'
import type { Map } from 'leaflet'

const { defaultZoom } = mapConfig

export function updateRoute (root, lat, lng, zoom = defaultZoom) {
  lat = truncateDecimals(lat)
  lng = truncateDecimals(lng)
  // Keep only defined parameters in the route
  // Allow to pass a custom root to let it be used in multiple modules
  const route = buildPath(root, { lat, lng, zoom })
  app.navigate(route, { preventScrollTop: true })
}

export function updateMarker (marker: Marker, coords: { lat: number, lng: number }) {
  if (coords?.lat == null) return marker.remove()
  const { lat, lng } = coords
  return marker.setLatLng([ lat, lng ])
}

export function getBbox (map: Map) {
  // @ts-expect-error
  const { _southWest, _northEast } = map.getBounds()
  if (_southWest.lng === _northEast.lng || _southWest.lat === _northEast.lat) {
    return
  }
  return [ _southWest.lng, _southWest.lat, _northEast.lng, _northEast.lat ] as BBox
}

export function uniqBounds (bounds: LatLng[]) {
  const stringifiedBounds = compact(bounds).map(stringifyBound)
  return uniq(stringifiedBounds).map(parseStringifiedBound) as LatLng[]
}

const stringifyBound = (latLng: LatLng) => JSON.stringify(latLng)
const parseStringifiedBound = (stringifiedBound: string) => JSON.parse(stringifiedBound)

export function isMapTooZoomedOut (mapZoom: number, displayedElementsCount: number) {
  if (mapZoom >= 10) return false
  if (!displayedElementsCount) return false
  return displayedElementsCount > 20
}
