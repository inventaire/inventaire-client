import { forceArray } from '#lib/utils'
import mapConfig from './config.js'
import { truncateDecimals } from './geo.js'
import { buildPath } from '#lib/location'
import error_ from '#lib/error'
import User from '#users/models/user'
import Group from '#groups/models/group'

const { defaultZoom } = mapConfig

export const showMainUserPositionPicker = async () => {
  await getLeaflet()
  return updatePosition(app.user, 'user:update', 'user')
}

export const getLeaflet = async () => {
  const [ { default: mapConfig } ] = await Promise.all([
    import('./config.js'),
    // Set window.L
    import('leaflet'),
    import('leaflet/dist/leaflet.css'),
    import('leaflet.markercluster/dist/MarkerCluster.css'),
    import('leaflet.markercluster/dist/MarkerCluster.Default.css'),
  ])
  // Needs to be initialized after window.L was set
  await import('leaflet.markercluster')
  const { init: onLeafletReady } = mapConfig
  onLeafletReady()
}

export async function showPositionPicker (options) {
  const { default: PositionPicker } = await import('../views/position_picker')
  app.layout.showChildView('modal', new PositionPicker(options))
}

export function updateRoute (root, lat, lng, zoom = defaultZoom) {
  lat = truncateDecimals(lat)
  lng = truncateDecimals(lng)
  // Keep only defined parameters in the route
  // Allow to pass a custom root to let it be used in multiple modules
  const route = buildPath(root, { lat, lng, zoom })
  app.navigate(route, { preventScrollTop: true })
}

export function updateRouteFromEvent (root, e) {
  const { lat, lng } = e.target.getCenter()
  const { _zoom } = e.target
  return updateRoute(root, lat, lng, _zoom)
}

export function updateMarker (marker, coords) {
  if (coords?.lat == null) return marker.remove()
  const { lat, lng } = coords
  return marker.setLatLng([ lat, lng ])
}

export function showOnMap (typeName, map, docs) {
  if (typeName === 'users') {
    const models = docs.map(doc => new User(doc))
    return showUsersOnMap(map, models)
  } else if (typeName === 'groups') {
    const models = docs.map(doc => new Group(doc))
    return showGroupsOnMap(map, models)
  } else {
    throw error_.new('invalid type', { typeName, map, docs })
  }
}

// Same as the above function, but guesses model type
export function showModelsOnMap (map, models) {
  for (const model of forceArray(models)) {
    const type = model.get('type')
    if (type === 'user') showUserOnMap(map, model)
    else if (type === 'group') showGroupOnMap(map, model)
    else showItemOnMap(map, model)
  }
}

export function showUsersOnMap (map, users) {
  return forceArray(users).map(user => showUserOnMap(map, user))
}

export function showGroupsOnMap (map, groups) {
  return forceArray(groups).map(group => showGroupOnMap(map, group))
}

export function BoundFilter (map) {
  const bounds = map.getBounds()
  return function (model) {
    if (!model.hasPosition()) return false
    const point = model.getLatLng()
    return bounds.contains(point)
  }
}

export function getBbox (map) {
  const { _southWest, _northEast } = map.getBounds()
  if (_southWest.lng === _northEast.lng || _southWest.lat === _northEast.lat) {
    return
  }
  return [ _southWest.lng, _southWest.lat, _northEast.lng, _northEast.lat ]
}

export function showUserOnMap (map, user) {
  // Substitude the main user model to the one created from user document
  // so that updates on the main user model are correctly displayed,
  // and to avoid to display duplicates
  if (user.id === app.user.id) {
    ;({ user } = app)
  }

  if (user.hasPosition()) {
    const marker = map.addMarker({
      objectId: `user-${user.id}`,
      model: user,
      markerType: 'user'
    })

    // map.addMarker will return undefined if the marker was already added
    // which allows here to not re-add the event listerner
    if (marker != null) {
      // Expose the main user marker to make it easier to update
      // on user position change
      if (user === app.user) map.mainUserMarker = marker
    }
  }
}

export function updatePosition (model, updateReqres, type, focusSelector) {
  showPositionPicker({
    model,
    type,
    focus: focusSelector,
    resolve (newCoords, selector) {
      return app.request(updateReqres, {
        attribute: 'position',
        value: newCoords,
        selector,
        // required by reqres updaters such as group:update:settings
        model
      })
    }
  })
}

const showGroupOnMap = function (map, group) {
  if (group.hasPosition()) {
    return map.addMarker({
      objectId: `group-${group.id}`,
      model: group,
      markerType: 'group'
    })
  }
}

const showItemOnMap = function (map, item) {
  if (item.position != null) {
    return map.addMarker({
      objectId: `item-${item.id}`,
      model: item,
      markerType: 'item'
    })
  }
}
