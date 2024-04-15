import app from '#app/app'
import type { ItemCategory, SerializedUser } from '#app/modules/users/lib/users'
import type { Entity } from '#app/types/entity'
import { getEntityLocalHref } from '#entities/lib/entities'
import { transactionsDataFactory, type TransactionData } from '#inventory/lib/transactions_data'
import { capitalize } from '#lib/utils'
import type { LatLng, Url } from '#server/types/common'
import type { EntityType } from '#server/types/entity'
import type { Item, ItemSnapshot, SerializedItem as ServerSerializedItem } from '#server/types/item'
import { hasOngoingTransactionsByItemIdSync } from '#transactions/lib/helpers'
import { i18n } from '#user/lib/i18n'

export interface SerializedItem extends ServerSerializedItem {
  authorized: boolean
  mainUserIsOwner: boolean
  restricted: boolean
  pathname: Url
  title: string
  subtitle: string
  personalizedTitle: string
  entityPathname: Url
  userReady: boolean
  isPrivate: boolean
  entityData?: Entity
  entityType?: EntityType
  currentTransaction: TransactionData
  hasActiveTransaction?: boolean
  image: ItemSnapshot['entity:image']
  authors: ItemSnapshot['entity:authors']
  series: ItemSnapshot['entity:series']
  ordinal: ItemSnapshot['entity:ordinal']
}

export function serializeItem (item: Item & Partial<SerializedItem>) {
  item.authorized = item.owner === app.user.id
  item.mainUserIsOwner = item.authorized
  item.restricted = !item.authorized

  Object.assign(item, {
    pathname: getItemPathname(item._id),
    title: item.snapshot['entity:title'],
    subtitle: item.snapshot['entity:subtitle'],
    image: item.snapshot['entity:image'],
    authors: item.snapshot['entity:authors'],
    series: item.snapshot['entity:series'],
    ordinal: item.snapshot['entity:ordinal'],
    personalizedTitle: findBestTitle(item),
    entityPathname: getEntityLocalHref(item.entity),
    userReady: item.userReady,
    isPrivate: item.visibility?.length === 0,
  })

  if (item.entityData != null) {
    const { type } = item.entityData
    item.entityType = type
    const Type = capitalize(type)
    item[`entityIs${Type}`] = true
  }

  const { transaction } = item
  const transacs = transactionsDataFactory()
  item.currentTransaction = transacs[transaction]
  item[transaction] = true

  if (item.restricted) {
    // used to hide the "request button" given accessible transactions
    // are necessarly involving the main user, which should be able
    // to have several transactions ongoing with a given item
    item.hasActiveTransaction = hasActiveTransaction(item._id)
  }

  return item as SerializedItem
}

export const getItemPathname = itemId => `/items/${itemId}`

export interface SerializedItemWithUserData extends SerializedItem {
  user: SerializedUser
  category: ItemCategory
  distanceFromMainUser?: number
  position?: LatLng
}

export function setItemUserData (item: SerializedItemWithUserData, user: SerializedUser) {
  item.user = user
  item.category = user.itemsCategory
  item.distanceFromMainUser = user.distanceFromMainUser
  item.position = user.position
  return item
}

function findBestTitle (item) {
  const title = item.snapshot['entity:title']
  const transaction = item.transaction
  if (item.user) {
    const context = i18n(`${transaction}_personalized`, { username: item.user.username })
    return `${title} - ${context}`
  } else {
    return title
  }
}

function hasActiveTransaction (itemId) {
  // the reqres 'has:transactions:ongoing:byItemId' wont be defined
  // if the user isn't logged in
  if (!app.user.loggedIn) return false
  return hasOngoingTransactionsByItemIdSync(itemId)
}

export function getItemLinkTitle ({ title, username, mainUserIsOwner }) {
  if (mainUserIsOwner) {
    return i18n('Edit your item "%{title}"', { title })
  } else {
    return i18n('Learn more about %{username}\'s item "%{title}"', { username, title })
  }
}
