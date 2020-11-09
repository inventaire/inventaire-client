import assert_ from 'lib/assert_types'
import map_ from 'modules/map/lib/map'
import getPositionFromNavigator from 'modules/map/lib/navigator_position'
import { startLoading, stopLoading } from 'modules/general/plugins/behaviors'
const { updateRoute, updateRouteFromEvent, BoundFilter } = map_
const containerId = 'mapContainer'
const containerSelector = '#' + containerId

export const initMap = async params => {
  const { view, query } = params

  // Do not redefine the updateRoute variable: access from params object
  if (params.updateRoute == null) { params.updateRoute = true }

  startLoading.call(view, containerSelector)

  const [ coords ] = await Promise.all([
    solvePosition(query),
    app.request('map:before')
  ])
  stopLoading.call(view, containerSelector)
  const map = drawMap(params, coords)
  initEventListners(params, map)
  return map
}

const solvePosition = function (coords = {}) {
  // priority is given to passed parameters
  const { lat, lng } = coords
  if ((lat != null) && (lng != null)) { return Promise.resolve(coords) }

  // then to the user saved position
  const { user } = app
  if (user.hasPosition()) { return Promise.resolve(user.getCoords()) }

  // finally a request for the user position is issued
  return getPositionFromNavigator(containerId)
}

const drawMap = function (params, coords) {
  const { lat, lng, zoom } = coords
  const { showObjects, path } = params

  const map = map_.draw({
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
