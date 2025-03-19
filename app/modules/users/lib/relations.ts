import { API } from '#app/api/api'
import app from '#app/app'
import log_ from '#app/lib/loggers'
import preq from '#app/lib/preq'
import type { RelationAction } from '#server/controllers/relations/actions'
import type { UserId } from '#server/types/user'
import { getCachedSerializedUsers } from '../helpers'
import type { SerializedUser } from './users'

export async function updateRelationStatus (user: SerializedUser, action: RelationAction) {
  const { _id: userId } = user
  await preq.post(API.relations, { action, user: userId })
}

export function initRelations () {
  if (app.user.loggedIn) {
    return preq.get(API.relations)
    .then(relations => {
      app.relations = relations
      app.execute('waiter:resolve', 'relations')
    })
    .catch(log_.Error('relations init err'))
  } else {
    app.relations = {
      friends: [],
      userRequested: [],
      otherRequested: [],
      network: [],
    }
    app.execute('waiter:resolve', 'relations')
  }
}

export async function getFriendshipRequests () {
  await app.request('wait:for', 'relations')
  const userIds = app.relations.otherRequested as UserId[]
  return getCachedSerializedUsers(userIds)
}
