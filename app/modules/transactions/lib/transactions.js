import app from '#app/app'
import preq from '#lib/preq'
import { transactionsData } from '#inventory/lib/transactions_data'
import { i18n } from '#user/lib/i18n'
import { getActionUserKey } from '#transactions/lib/transactions_actions'

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

const getNextActionsList = function (transactionName) {
  if (transactionName === 'lending') {
    return nextActionsWithReturn
  } else {
    return basicNextActions
  }
}

export const findNextActions = function (transacData) {
  const { name, state, mainUserIsOwner } = transacData
  const nextActions = getNextActionsList(name, state)
  const role = mainUserIsOwner ? 'owner' : 'requester'
  return nextActions[state][role]
}

const isActive = transacData => findNextActions(transacData) != null
export const isArchived = transacData => !isActive(transacData)

async function getTransactionsByItemId (itemId) {
  const { transactions } = await preq.get(app.API.transactions.byItem(itemId))
  return transactions
}

export async function getActiveTransactionsByItemId (itemId) {
  const transactions = await getTransactionsByItemId(itemId)
  return transactions.filter(isActive)
}

export function addTransactionDerivedData (transaction) {
  const { _id: id, owner } = transaction
  const mainUserIsOwner = owner === app.user.id
  const mainUserRole = mainUserIsOwner ? 'owner' : 'requester'
  const mainUserRead = transaction.read[mainUserRole]
  const transactionMode = transactionsData[transaction.transaction]
  return Object.assign(transaction, {
    pathname: `/transactions/${id}`,
    mainUserRole,
    mainUserIsOwner,
    mainUserRead,
    transactionMode,
  })
}

export async function grabUsers (transaction) {
  if (transaction.mainUserIsOwner) {
    transaction.owner = app.user.toJSON()
  } else {
    transaction.requester = app.user.toJSON()
  }
}

export function getTransactionStateText ({ transaction, withLink = false }) {
  const lastAction = transaction.actions.at(-1)
  const userKey = getActionUserKey(lastAction, transaction)
  const actionName = lastAction.action
  const otherUsername = getOtherUsername(transaction)
  return i18n(`${userKey}_user_${actionName}`, { username: formatUsername(otherUsername, withLink) })
}

const getOtherUserRole = transaction => {
  if (transaction.mainUserIsOwner) return 'requester'
  else return 'owner'
}

const getOtherUsername = transaction => {
  const otherUserRole = getOtherUserRole(transaction)
  return transaction.snapshot[otherUserRole].username
}

const formatUsername = (username, withLink) => {
  // injecting an html anchor instead of just a username string
  if (withLink) {
    return `<a href="/users/${username}/inventory" class="username">${username}</a>`
  } else {
    return username
  }
}
