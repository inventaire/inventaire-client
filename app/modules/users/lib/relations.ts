import { API } from '#app/api/api'
import app from '#app/app'
import log_ from '#app/lib/loggers'
import preq from '#app/lib/preq'

export async function updateRelationStatus ({ user, action }) {
  const { _id: userId } = user
  return preq.post(API.relations, { action, user: userId })
}

export const initRelations = function () {
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
