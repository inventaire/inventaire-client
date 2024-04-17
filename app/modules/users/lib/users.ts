import app from '#app/app'
import { buildPath } from '#app/lib/location'
import { images } from '#app/lib/urls'
import { distanceBetween } from '#map/lib/geo'
import type { RelativeUrl } from '#server/types/common'
import type { User } from '#server/types/user'

const { defaultAvatar } = images

export type ItemCategory = 'personal' | 'network' | 'public' | 'nearbyPublic' | 'otherPublic'

export interface SerializedUser extends User {
  isMainUser: boolean
  kmDistanceFormMainUser: number
  distanceFromMainUser: number
  itemsCategory: ItemCategory
  pathname: RelativeUrl
  inventoryPathname: RelativeUrl
  listingsPathname: RelativeUrl
  contributionsPathname: RelativeUrl
}

export function serializeUser (user: User & Partial<SerializedUser>) {
  user.isMainUser = user._id === app.user.id
  user.picture = getPicture(user)
  setDistance(user)
  setItemsCategory(user)
  Object.assign(user, getUserPathnames(user.username))
  return user
}

export function getPicture (user) {
  return user.picture || defaultAvatar
}

export function setDistance (user) {
  if (user.distanceFromMainUser != null) return
  if (!(app.user.has('position') && user.position)) return
  const a = app.user.getCoords()
  const b = getCoords(user)
  const distance = distanceBetween(a, b)
  user.kmDistanceFormMainUser = distance
  // Under 20km, return a ~100m precision to signal the fact that location
  // aren't precise to the meter or anything close to it
  // Above, return a ~1km precision
  const precision = distance > 20 ? 0 : 1
  user.distanceFromMainUser = Number(distance.toFixed(precision)).toLocaleString(app.user.lang)
}

function getCoords (user) {
  const latLng = user.position
  if (latLng instanceof Array) {
    const [ lat, lng ] = latLng
    return { lat, lng }
  } else if (latLng != null) {
    return latLng
  } else {
    return {}
  }
}

export function setItemsCategory (user) {
  if (user._id === app.user.id) {
    user.itemsCategory = 'personal'
  } else if (app.relations.network.includes(user._id)) {
    user.itemsCategory = 'network'
  } else {
    user.itemsCategory = 'public'
  }
}

export function getUserBasePathname (usernameOrId) {
  return `/users/${usernameOrId.toLowerCase()}`
}

export function getUserPathnames (username: string) {
  const base = getUserBasePathname(username)
  return {
    pathname: base,
    inventoryPathname: `${base}/inventory`,
    listingsPathname: `${base}/lists`,
    contributionsPathname: `${base}/contributions`,
  }
}

export function getPositionUrl (user) {
  if (user.distanceFromMainUser == null) return
  const [ lat, lng ] = user.position
  return buildPath('/network/users/nearby', { lat, lng })
}
