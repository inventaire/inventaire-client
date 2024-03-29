import app from '#app/app'
import log_ from '#lib/loggers'
import preq from '#lib/preq'
import { transactionsData } from '#inventory/lib/transactions_data'
import { i18n } from '#user/lib/i18n'
import { getActionUserKey } from '#transactions/lib/transactions_actions'
import assert_ from '#lib/assert_types'
import { getUsersByIds } from '#users/users_data'
import { serializeUser } from '#users/lib/users'
import { buildPath } from '#lib/location'
import { timeFromNow } from '#lib/time'

// Keep in sync with server/models/attributes/transaction
const basicNextActions = {
  // current state:
  requested: {
    // key: main user role in this transaction
    // value: possible actions
    owner: 'accept/decline',
    requester: 'waiting:accepted'
  },
  accepted: {
    owner: 'waiting:confirmed',
    requester: 'confirm'
  },
  declined: {
    owner: null,
    requester: null
  },
  confirmed: {
    owner: null,
    requester: null
  },
  cancelled: {
    owner: null,
    requester: null
  }
}

// customizing actions for transactions where the item should be returned
// currently only 'lending'
const nextActionsWithReturn = _.extend({}, basicNextActions, {
  confirmed: {
    owner: 'returned',
    requester: 'waiting:returned'
  },
  returned: {
    owner: null,
    requester: null
  }
})

function getNextActionsList (transactionName) {
  assert_.string(transactionName)
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
  const { transactions } = await preq.get(app.API.transactions.byItem(itemId))
  return transactions
}

export async function getActiveTransactionsByItemId (itemId) {
  const transactions = await getTransactionsByItemId(itemId)
  return transactions.filter(isOngoing)
}

export function serializeTransaction (transaction) {
  const { _id: id, owner, snapshot } = transaction
  const mainUserIsOwner = owner === app.user.id
  const mainUserRole = mainUserIsOwner ? 'owner' : 'requester'
  snapshot.other = mainUserIsOwner ? snapshot.requester : snapshot.owner
  const mainUserRead = transaction.read[mainUserRole]
  const transactionMode = transactionsData[transaction.transaction]
  return Object.assign(transaction, {
    pathname: `/transactions/${id}`,
    mainUserRole,
    mainUserIsOwner,
    mainUserRead,
    transactionMode,
    archived: isArchived(transaction),
  })
}

export async function grabUsers (transaction) {
  if (transaction.mainUserIsOwner) {
    transaction.owner = app.user.toJSON()
  } else {
    transaction.requester = app.user.toJSON()
  }
}

export function getTransactionStateText ({ transaction, action }) {
  if (!action) {
    const lastAction = transaction.actions.at(-1)
    action = lastAction
  }
  const userKey = getActionUserKey(action, transaction)
  const { action: actionName } = action
  const otherUsername = getOtherUsername(transaction)
  return i18n(`${userKey}_user_${actionName}`, { username: otherUsername })
}

const getOtherUserRole = transaction => {
  if (transaction.mainUserIsOwner) return 'requester'
  else return 'owner'
}

const getOtherUsername = transaction => {
  const otherUserRole = getOtherUserRole(transaction)
  return transaction.snapshot[otherUserRole].username
}

export async function attachLinkedDocs (transaction) {
  if (transaction.docs) return
  transaction.docs = {}
  await Promise.all([
    attachUsers(transaction),
    attachMessages(transaction),
  ])
}

async function attachUsers (transaction) {
  const { requester, owner } = transaction
  const usersByIds = await getUsersByIds([ requester, owner ])
  transaction.docs.requester = serializeUser(usersByIds[requester])
  transaction.docs.owner = serializeUser(usersByIds[owner])
  transaction.docs.usersByIds = usersByIds
}

export function getTransactionContext (transaction) {
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

async function attachMessages (transaction) {
  const { messages } = await preq.get(buildPath(app.API.transactions.base, {
    action: 'get-messages',
    transaction: transaction._id,
  }))
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
    await preq.put(app.API.transactions.base, {
      id: transaction._id,
      action: 'mark-as-read'
    })
    transaction.read[transaction.mainUserRole] = true
    transaction.mainUserRead = true
    app.vent.trigger('transactions:unread:change')
  } catch (err) {
    log_.error(err, 'markAsRead')
  }
}

export async function updateTransactionState ({ transaction, state }) {
  const res = await preq.put(app.API.transactions.base, {
    transaction: transaction._id,
    state,
    action: 'update-state'
  })
  Object.assign(transaction, serializeTransaction(res.transaction))
  return transaction
}
