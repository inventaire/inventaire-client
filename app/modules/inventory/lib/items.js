import { getEntityLocalHref } from '#entities/lib/entities'
import { transactionsDataFactory } from '#inventory/lib/transactions_data'
import { capitalize } from '#lib/utils'
import { hasOngoingTransactionsByItemIdSync } from '#transactions/helpers'
import { i18n } from '#user/lib/i18n'

export function serializeItem (item) {
  item.authorized = item.owner === app.user.id
  item.mainUserIsOwner = item.authorized
  item.restricted = !item.authorized

  Object.assign(item, {
    pathname: `/items/${item._id}`,
    title: item.snapshot['entity:title'],
    subtitle: item.snapshot['entity:subtitle'],
    authors: item.snapshot['entity:authors'],
    personalizedTitle: findBestTitle(item),
    entityPathname: getEntityLocalHref(item.entity),
    userReady: item.userReady,
    mainUserIsOwner: item.mainUserIsOwner,
    isPrivate: item.visibility?.length === 0
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

  item.image = item.snapshot['entity:image']
  item.authors = item.snapshot['entity:authors']
  item.series = item.snapshot['entity:series']
  item.ordinal = item.snapshot['entity:ordinal']

  return item
}

export function setItemUserData (item, user) {
  item.user = user
  item.category = user.itemsCategory
  item.distanceFromMainUser = user.distanceFromMainUser
  item.position = user.position
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
