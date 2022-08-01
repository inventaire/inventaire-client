import assert_ from '#lib/assert_types'
import { ownerActions } from '#transactions/models/action'

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
