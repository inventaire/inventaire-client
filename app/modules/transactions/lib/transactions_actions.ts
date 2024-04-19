import assert_ from '#app/lib/assert_types'
import { cancellableStates } from '#transactions/lib/cancellable_states'

export function getActionUserKey (action, transaction) {
  const actionName = action.action
  const { mainUserIsOwner } = transaction
  // The transaction object should have been enriched before
  assert_.boolean(mainUserIsOwner)
  let actorRole
  if (action.actor) {
    actorRole = action.actor
  } else if (ownerActions.includes(actionName)) {
    actorRole = 'owner'
  } else {
    actorRole = 'requester'
  }
  if (mainUserIsOwner) {
    if (actorRole === 'owner') return 'main'
    else return 'other'
  } else {
    if (actorRole === 'owner') return 'other'
    else return 'main'
  }
}

export const actorCanBeBoth = [ 'cancelled' ]

export const ownerActions = [
  'accepted',
  'declined',
  'returned',
]

export function transactionIsCancellable (transaction) {
  const { transaction: transactionMode, mainUserRole } = transaction
  const lastAction = transaction.actions.at(-1)
  const state = lastAction.action
  return cancellableStates[transactionMode][mainUserRole].includes(state)
}
