import log_ from '#lib/loggers'
import preq from '#lib/preq'

export async function updateRelationStatus ({ user, action }) {
  const { _id: userId } = user
  return preq.post(app.API.relations, { action, user: userId })
}

export const initRelations = function () {
  if (app.user.loggedIn) {
    return preq.get(app.API.relations)
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
