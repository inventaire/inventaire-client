/* eslint-disable
    import/no-duplicates,
    no-return-assign,
    no-undef,
    no-unused-vars,
    no-var,
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
import Config from './config'

import getCurrentPosition from './navigator_position'
import Geo from './geo'

import smartPreventDefault from 'modules/general/lib/smart_prevent_default'
import { buildPath } from 'lib/location'
import error_ from 'lib/error'
let map_

const {
  defaultZoom
} = Config

const {
  truncateDecimals
} = Geo

export default map_ = {
  draw: require('./draw'),

  updateRoute (root, lat, lng, zoom = defaultZoom) {
    lat = truncateDecimals(lat)
    lng = truncateDecimals(lng)
    // Keep only defined parameters in the route
    // Allow to pass a custom root to let it be used in multiple modules
    const route = buildPath(root, { lat, lng, zoom })
    return app.navigate(route, { preventScrollTop: true })
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
    return (() => {
      const result = []
      for (const model of _.forceArray(models)) {
        switch (model.get('type')) {
        case 'user': result.push(map_.showUserOnMap(map, model)); break
        case 'group': result.push(showGroupOnMap(map, model)); break
        default: result.push(showItemOnMap(map, model))
        }
      }
      return result
    })()
  },

  showUsersOnMap (map, users) {
    return _.forceArray(users).map(user => map_.showUserOnMap(map, user))
  },

  showGroupsOnMap (map, groups) {
    return _.forceArray(groups).map(group => showGroupOnMap(map, group))
  },

  BoundFilter (map) {
    let filter
    const bounds = map.getBounds()
    return filter = function (model) {
      if (!model.hasPosition()) { return false }
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
        if (user === app.user) { return map.mainUserMarker = marker }
      }
    }
  }
}

var showGroupOnMap = function (map, group) {
  if (group.hasPosition()) {
    return map.addMarker({
      objectId: group.cid,
      model: group,
      markerType: 'group'
    })
  }
}

var showItemOnMap = function (map, item) {
  if (item.position != null) {
    return map.addMarker({
      objectId: item.cid,
      model: item,
      markerType: 'item'
    })
  }
}
