import { forceArray } from 'lib/utils'
import mapConfig from './config'
import { truncateDecimals } from './geo'
import { buildPath } from 'lib/location'
import error_ from 'lib/error'
import draw from './draw'

const { defaultZoom } = mapConfig

let map_
export default map_ = {
  draw,

  updateRoute (root, lat, lng, zoom = defaultZoom) {
    lat = truncateDecimals(lat)
    lng = truncateDecimals(lng)
    // Keep only defined parameters in the route
    // Allow to pass a custom root to let it be used in multiple modules
    const route = buildPath(root, { lat, lng, zoom })
    app.navigate(route, { preventScrollTop: true })
  },

  updateRouteFromEvent (root, e) {
    const { lat, lng } = e.target.getCenter()
    const { _zoom } = e.target
    return map_.updateRoute(root, lat, lng, _zoom)
  },

  updateMarker (marker, coords) {
    if (coords?.lat == null) { return marker.remove() }
    const { lat, lng } = coords
    return marker.setLatLng([ lat, lng ])
  },

  showOnMap (typeName, map, models) {
    if (typeName === 'users') {
      return map_.showUsersOnMap(map, models)
    } else if (typeName === 'groups') {
      return map_.showGroupsOnMap(map, models)
    } else { throw error_.new('invalid type', { typeName, map, models }) }
  },

  // Same as the above function, but guesses model type
  showModelsOnMap (map, models) {
    for (const model of forceArray(models)) {
      const type = model.get('type')
      if (type === 'user') map_.showUserOnMap(map, model)
      else if (type === 'group') showGroupOnMap(map, model)
      else showItemOnMap(map, model)
    }
  },

  showUsersOnMap (map, users) {
    return forceArray(users).map(user => map_.showUserOnMap(map, user))
  },

  showGroupsOnMap (map, groups) {
    return forceArray(groups).map(group => showGroupOnMap(map, group))
  },

  BoundFilter (map) {
    const bounds = map.getBounds()
    return function (model) {
      if (!model.hasPosition()) return false
      const point = model.getLatLng()
      return bounds.contains(point)
    }
  },

  getBbox (map) {
    const { _southWest, _northEast } = map.getBounds()
    return [ _southWest.lng, _southWest.lat, _northEast.lng, _northEast.lat ]
  },

  showUserOnMap (map, user) {
    // Substitude the main user model to the one created from user document
    // so that updates on the main user model are correctly displayed,
    // and to avoid to display duplicates
    if (user.id === app.user.id) {
      ({
        user
      } = app)
    }

    if (user.hasPosition()) {
      const marker = map.addMarker({
        objectId: user.cid,
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
}

const showGroupOnMap = function (map, group) {
  if (group.hasPosition()) {
    return map.addMarker({
      objectId: group.cid,
      model: group,
      markerType: 'group'
    })
  }
}

const showItemOnMap = function (map, item) {
  if (item.position != null) {
    return map.addMarker({
      objectId: item.cid,
      model: item,
      markerType: 'item'
    })
  }
}
