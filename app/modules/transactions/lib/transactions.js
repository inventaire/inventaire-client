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
  } else { return basicNextActions }
}

const findNextActions = function (transacData) {
  const { name, state, mainUserIsOwner } = transacData
  const nextActions = getNextActionsList(name, state)
  const role = mainUserIsOwner ? 'owner' : 'requester'
  return nextActions[state][role]
}

const isActive = transacData => findNextActions(transacData) != null
const isArchived = transacData => !isActive(transacData)

export { findNextActions, isArchived }
