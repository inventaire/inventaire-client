import { API } from '#app/api/api'
import { assertString } from '#app/lib/assert_types'
import { buildPath } from '#app/lib/location'
import log_ from '#app/lib/loggers'
import preq from '#app/lib/preq'
import { timeFromNow } from '#app/lib/time'
import { vent } from '#app/radio'
import { transactionsData, type TransactionData } from '#inventory/lib/transactions_data'
import type { GetTransactionsMessagesResponse } from '#server/controllers/transactions/get_messages'
import type { TransactionComment } from '#server/types/comment'
import type { RelativeUrl } from '#server/types/common'
import type { Transaction, TransactionAction } from '#server/types/transaction'
import type { UserId } from '#server/types/user'
import { getActionUserKey } from '#transactions/lib/transactions_actions'
import { i18n } from '#user/lib/i18n'
import { mainUser } from '#user/lib/main_user'
import { serializeUser, type SerializedUser, type ServerUser } from '#users/lib/users'
import { getUsersByIds } from '#users/users_data'
import type { OverrideProperties } from 'type-fest'

// Keep in sync with server/models/attributes/transaction
const basicNextActions = {
  // current state:
  requested: {
    // key: main user role in this transaction
    // value: possible actions
    owner: 'accept/decline',
    requester: 'waiting:accepted',
  },
  accepted: {
    owner: 'waiting:confirmed',
    requester: 'confirm',
  },
  declined: {
    owner: null,
    requester: null,
  },
  confirmed: {
    owner: null,
    requester: null,
  },
  cancelled: {
    owner: null,
    requester: null,
  },
}

// customizing actions for transactions where the item should be returned
// currently only 'lending'
const nextActionsWithReturn = Object.assign({}, basicNextActions, {
  confirmed: {
    owner: 'returned',
    requester: 'waiting:returned',
  },
  returned: {
    owner: null,
    requester: null,
  },
})

function getNextActionsList (transactionName) {
  assertString(transactionName)
  if (transactionName === 'lending') {
    return nextActionsWithReturn
  } else {
    return basicNextActions
  }
}

export function findNextActions (transacData) {
  const { transaction: transactionName, state, mainUserIsOwner } = transacData
  const nextActions = getNextActionsList(transactionName)
  const role = mainUserIsOwner ? 'owner' : 'requester'
  return nextActions[state][role]
}

export const isOngoing = transacData => findNextActions(transacData) != null
export const isArchived = transacData => !isOngoing(transacData)

async function getTransactionsByItemId (itemId) {
  const { transactions } = await preq.get(API.transactions.byItem(itemId))
  return transactions
}

export async function getActiveTransactionsByItemId (itemId) {
  const transactions = await getTransactionsByItemId(itemId)
  return transactions.filter(isOngoing)
}

interface SerializedTransactionOverrides {
  snapshot: Transaction['snapshot'] & { other: SerializedUser }
}

interface SerializedTransactionExtra {
  pathname: RelativeUrl
  updated: EpochTimeStamp
  mainUserRole: 'owner' | 'requester'
  mainUserIsOwner: boolean
  mainUserRead: boolean
  transactionMode: TransactionData
  archived: boolean
}

interface TransactionLinkedDocs {
  docs: {
    requester: SerializedUser
    owner: SerializedUser
    usersByIds: Record<UserId, ServerUser>
  }
  messages: TransactionComment[]
}

export type SerializedTransaction = OverrideProperties<Transaction, SerializedTransactionOverrides> & SerializedTransactionExtra & TransactionLinkedDocs

export function serializeTransaction (transaction: Transaction) {
  const { _id: id, owner, snapshot, actions } = transaction
  const mainUserIsOwner = owner === mainUser?._id
  const mainUserRole = mainUserIsOwner ? 'owner' : 'requester'
  // @ts-expect-error
  snapshot.other = mainUserIsOwner ? snapshot.requester : snapshot.owner
  const mainUserRead = transaction.read[mainUserRole]
  const transactionMode = transactionsData[transaction.transaction]
  return Object.assign(transaction, {
    pathname: `/transactions/${id}`,
    updated: actions.at(-1).timestamp,
    mainUserRole,
    mainUserIsOwner,
    mainUserRead,
    transactionMode,
    archived: isArchived(transaction),
  }) as SerializedTransaction
}

export async function grabUsers (transaction) {
  if (transaction.mainUserIsOwner) {
    transaction.owner = mainUser
  } else {
    transaction.requester = mainUser
  }
}

export function getTransactionStateText ({ transaction, action }: { transaction: Transaction, action?: TransactionAction }) {
  if (!action) {
    const lastAction = transaction.actions.at(-1)
    action = lastAction
  }
  const userKey = getActionUserKey(action, transaction)
  const { action: actionName } = action
  const otherUsername = getOtherUsername(transaction)
  return i18n(`${userKey}_user_${actionName}`, { username: otherUsername })
}

function getOtherUserRole (transaction) {
  if (transaction.mainUserIsOwner) return 'requester'
  else return 'owner'
}

function getOtherUsername (transaction) {
  const otherUserRole = getOtherUserRole(transaction)
  return transaction.snapshot[otherUserRole].username
}

export async function attachLinkedDocs (transaction: SerializedTransaction) {
  if (transaction.docs) return
  // @ts-expect-error
  transaction.docs = {}
  await Promise.all([
    attachUsers(transaction),
    attachMessages(transaction),
  ])
}

async function attachUsers (transaction: SerializedTransaction) {
  const { requester, owner } = transaction
  const usersByIds = await getUsersByIds([ requester, owner ])
  transaction.docs.requester = serializeUser(usersByIds[requester])
  transaction.docs.owner = serializeUser(usersByIds[owner])
  transaction.docs.usersByIds = usersByIds
}

export function getTransactionContext (transaction: SerializedTransaction) {
  const { owner } = transaction.docs
  if (owner != null) {
    const { name: transactionName } = transaction.transactionMode
    if (transaction.mainUserIsOwner) {
      return i18n(`main_user_${transactionName}`)
    } else {
      const { username, pathname } = owner
      const link = `<a href='${pathname}'>${username}</a>`
      return i18n(`other_user_${transactionName}`, { username: link })
    }
  }
}

export const actionsIcons = {
  requested: 'envelope',
  accepted: 'check',
  confirmed: 'sign-in',
  declined: 'times',
  cancelled: 'times',
  returned: 'check',
}

async function attachMessages (transaction: SerializedTransaction) {
  const { messages } = (await preq.get(buildPath(API.transactions.base, {
    action: 'get-messages',
    transaction: transaction._id,
  }))) as GetTransactionsMessagesResponse
  transaction.messages = messages
}

export function buildTimeline (transaction) {
  const { actions, messages, docs } = transaction
  messages.forEach(messageDoc => {
    messageDoc.userDoc = docs.usersByIds[messageDoc.user]
  })
  const timeline = actions.concat(messages)
    .sort((a, b) => getEventTimestamp(a) - getEventTimestamp(b))

  timeline.forEach(setSameMessageGroupFlag(timeline))

  return timeline
}

const setSameMessageGroupFlag = timeline => (event, index) => {
  const previousEvent = timeline[index - 1]
  if (previousEvent && event.message && previousEvent.message && event.user === previousEvent.user) {
    event.sameUser = true
    event.sameMessageGroup = (timeFromNow(event.created) === timeFromNow(previousEvent.created))
  }
}

const getEventTimestamp = actionOrMessage => actionOrMessage.created || actionOrMessage.timestamp

export function getUnreadTransactionsListCount (transactions) {
  return transactions.filter(transaction => !transaction.mainUserRead).length
}

export async function markAsRead (transaction) {
  if (transaction.mainUserRead) return
  try {
    await preq.put(API.transactions.base, {
      id: transaction._id,
      action: 'mark-as-read',
    })
    transaction.read[transaction.mainUserRole] = true
    transaction.mainUserRead = true
    vent.trigger('transactions:unread:change')
  } catch (err) {
    log_.error(err, 'markAsRead')
  }
}

export async function updateTransactionState ({ transaction, state }) {
  const res = await preq.put(API.transactions.base, {
    transaction: transaction._id,
    state,
    action: 'update-state',
  })
  Object.assign(transaction, serializeTransaction(res.transaction))
  return transaction
}
