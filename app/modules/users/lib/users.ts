import app from '#app/app'
import { config } from '#app/config'
import assert_ from '#app/lib/assert_types'
import { buildPath } from '#app/lib/location'
import { images } from '#app/lib/urls'
import { countListings } from '#listings/lib/listings'
import { distanceBetween } from '#map/lib/geo'
import type { InstanceAgnosticContributor } from '#server/controllers/user/lib/anonymizable_user'
import type { GetUsersByIdsResponse } from '#server/controllers/users/by_ids'
import type { Host, RelativeUrl } from '#server/types/common'
import type { AssetImagePath, UserImagePath } from '#server/types/image'
import type { UserAccountUri } from '#server/types/server'
import type { AnonymizableUserId, SnapshotVisibilitySection, Username } from '#server/types/user'
import { countShelves } from '#shelves/lib/shelves'
import { relations } from './relations'
import type { OverrideProperties } from 'type-fest'

const { publicHost } = config
const { defaultAvatar } = images

export type ItemCategory = 'personal' | 'network' | 'public' | 'nearbyPublic' | 'otherPublic'

export type ServerUser = GetUsersByIdsResponse['users'][number]

export interface SerializedUserExtra {
  isMainUser: boolean
  kmDistanceFormMainUser: number
  distanceFromMainUser: number
  itemsCategory: ItemCategory
  pathname: RelativeUrl
  inventoryPathname: RelativeUrl
  listingsPathname: RelativeUrl
  contributionsPathname: RelativeUrl
  acct?: UserAccountUri
  itemsCount?: number
  itemsLastAdded?: EpochTimeStamp
  shelvesCount?: number
  listingsCount?: number
}

export interface SerializedUserOverrides {
  picture: UserImagePath | AssetImagePath
  bio: string | undefined
  created: EpochTimeStamp | undefined
  fediversable: boolean | undefined
}

// @ts-expect-error picture override conflicts with `picture: never` from DeletedUser and such
export type SerializedUser = OverrideProperties<ServerUser, SerializedUserOverrides> & SerializedUserExtra

// @ts-expect-error
export interface SerializedContributor extends InstanceAgnosticContributor {
  isMainUser: boolean
  handle: Username | `${Username}@${Host}`
  pathname?: RelativeUrl
  inventoryPathname?: RelativeUrl
  listingsPathname?: RelativeUrl
  contributionsPathname: RelativeUrl
  special: boolean
  deleted: boolean
  picture: UserImagePath | AssetImagePath
  distanceFromMainUser?: number
}

export function serializeUser (user: (ServerUser & Partial<SerializedUser>) | SerializedUser) {
  if ('pathname' in user) return user as SerializedUser
  user.isMainUser = user._id === app.user._id
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
  // @ts-expect-error
  user.picture = getPicture(user)
  Object.assign(user, getUserPathnames(user))
  user.special ??= false
  user.deleted ??= false
  return user as SerializedContributor
}

export function getPicture (user: Partial<SerializedUser>) {
  return user.picture || defaultAvatar
}

export function setDistance (user) {
  if (user.distanceFromMainUser != null) return
  if (!(app.user.position && user.position)) return
  const a = getCoords(app.user)
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
  if (user._id === app.user._id) {
    user.itemsCategory = 'personal'
  } else if (relations.network.includes(user._id)) {
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

export async function setInventoryStats (user: SerializedUser) {
  const created = user.created || 0
  // Make lastAdd default to the user creation date
  let data = { itemsCount: 0, lastAdd: created }

  // Known case of missing snapshot data: deleted users, user documents return from search
  const snapshot = 'snapshot' in user ? user.snapshot : null
  if (snapshot != null) {
    // @ts-ignore
    data = Object.values(snapshot).reduce(aggregateScoreData, data)
  }

  const { itemsCount, lastAdd } = data
  user.itemsCount = itemsCount
  user.itemsLastAdded = lastAdd

  const [ shelvesCount, listingsCount ] = await Promise.all([
    countShelves(user._id),
    countListings(user._id),
  ])
  user.shelvesCount = shelvesCount
  user.listingsCount = listingsCount
}

function aggregateScoreData (data: { itemsCount: number, lastAdd: EpochTimeStamp }, snapshotSection: SnapshotVisibilitySection) {
  const { 'items:count': count, 'items:last-add': lastAdd } = snapshotSection
  data.itemsCount += count
  if (lastAdd > data.lastAdd) data.lastAdd = lastAdd
  return data
}
