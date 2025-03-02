import app from '#app/app'
import { config } from '#app/config'
import assert_ from '#app/lib/assert_types'
import { buildPath } from '#app/lib/location'
import { images } from '#app/lib/urls'
import { distanceBetween } from '#map/lib/geo'
import type { InstanceAgnosticContributor } from '#server/controllers/user/lib/anonymizable_user'
import type { Host, RelativeUrl } from '#server/types/common'
import type { UserAccountUri } from '#server/types/server'
import type { AnonymizableUserId, User, Username } from '#server/types/user'

const { publicHost } = config
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
  acct?: UserAccountUri
}

export interface SerializedContributor extends InstanceAgnosticContributor {
  isMainUser: boolean
  handle: Username | `${Username}@${Host}`
  pathname?: RelativeUrl
  inventoryPathname?: RelativeUrl
  listingsPathname?: RelativeUrl
  contributionsPathname: RelativeUrl
  special: boolean
  deleted: boolean
}

export function serializeUser (user: User & Partial<SerializedUser>) {
  user.isMainUser = user._id === app.user.id
  if ('anonymizableId' in user) {
    user.acct = getLocalUserAccount(user.anonymizableId)
  }
  user.picture = getPicture(user)
  setDistance(user)
  setItemsCategory(user)
  Object.assign(user, getUserPathnames(user))
  return user as SerializedUser
}

export function serializeContributor (user: InstanceAgnosticContributor & Partial<SerializedContributor>) {
  user.isMainUser = user.acct === app.user.acct
  const host = user.acct.split('@')[1]
  if (host === publicHost) {
    user.handle = user.username
  } else {
    user.handle = `${user.username}@${host}`
  }
  user.picture = getPicture(user)
  Object.assign(user, getUserPathnames(user))
  user.special ??= false
  user.deleted ??= false
  return user as SerializedContributor
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

export function getUserBasePathname (usernameOrId: string) {
  return `/users/${usernameOrId.toLowerCase()}`
}

export function getUserPathnames (user: { username?: Username, acct?: UserAccountUri }) {
  if ('acct' in user && user.acct.split('@')[1] !== publicHost) {
    const { acct, username } = user
    const host = acct.split('@')[1]
    const base = getUserBasePathname(acct)
    const pathnames = {
      contributionsPathname: `${base}/contributions`,
    }
    if (username) {
      // Assume that protocol is the same: http in dev, https in prod
      const remoteBase = `${location.protocol}//${host}${getUserBasePathname(username)}`
      Object.assign(pathnames, {
        pathname: remoteBase,
        inventoryPathname: `${remoteBase}/inventory`,
        listingsPathname: `${remoteBase}/lists`,
      })
    }
    return pathnames
  } else {
    const base = getUserBasePathname(user.username || user.acct)
    return {
      pathname: base,
      inventoryPathname: `${base}/inventory`,
      listingsPathname: `${base}/lists`,
      contributionsPathname: `${base}/contributions`,
    }
  }
}

export function getPositionUrl (user) {
  if (user.distanceFromMainUser == null) return
  const [ lat, lng ] = user.position
  return buildPath('/network/users/nearby', { lat, lng })
}

export function getLocalUserAccount (anonymizableId: AnonymizableUserId) {
  assert_.string(anonymizableId)
  return `${anonymizableId}@${publicHost}` as UserAccountUri
}
