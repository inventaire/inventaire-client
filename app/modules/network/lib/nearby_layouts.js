import assert_ from '#lib/assert_types'
import getPositionFromNavigator from '#map/lib/navigator_position'
import { startLoading, stopLoading } from '#general/plugins/behaviors'
import { updateRoute, updateRouteFromEvent, BoundFilter, getLeaflet } from '#map/lib/map'
import { drawMap } from '#map/lib/draw'
const containerId = 'mapContainer'
const containerSelector = '#' + containerId

export const initMap = async params => {
  const { view, query } = params

  // Do not redefine the updateRoute variable: access from params object
  if (params.updateRoute == null) params.updateRoute = true

  startLoading.call(view, containerSelector)

  const [ coords ] = await Promise.all([
    solvePosition(query),
    getLeaflet()
  ])
  stopLoading.call(view, containerSelector)
  const map = drawLayoutMap(params, coords)
  initEventListners(params, map)
  return map
}

export const solvePosition = async function (coords = {}) {
  // priority is given to passed parameters
  const { lat, lng } = coords
  if ((lat != null) && (lng != null)) return coords

  // then to the user saved position
  const { user } = app
  if (user.hasPosition()) return user.getCoords()

  // finally a request for the user position is issued
  return getPositionFromNavigator(containerId)
}

const drawLayoutMap = function (params, coords) {
  const { lat, lng, zoom } = coords
  const { showObjects, path } = params

  const map = drawMap({
    containerId,
    latLng: [ lat, lng ],
    zoom,
    cluster: true
  })

  showObjects(map)

  if (params.updateRoute) updateRoute(path, lat, lng, zoom)

  assert_.object(map)
  return map
}

const initEventListners = (params, map) => {
  assert_.object(map)
  const { path, onMoveend } = params

  if (params.updateRoute) {
    assert_.string(path)
    map.on('moveend', updateRouteFromEvent.bind(null, path))
  }

  map.on('moveend', onMoveend)
}
export function grabMap (map) {
  assert_.object(map)
  assert_.function(map.getBounds)
  this.map = map
  return map
}

export function refreshListFilter (collection) {
  collection = collection || this.collection
  return collection.filterBy('geobox', BoundFilter(this.map))
}
