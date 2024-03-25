import { isModel } from '#lib/boolean_tests'
import log_ from '#lib/loggers'
import preq from '#lib/preq'

export default function (app) {
  const action = function (user, action, newStatus) {
    let userId;
    [ user, userId ] = normalizeUser(user)
    const currentStatus = user.get('status')
    user.set('status', newStatus)

    return preq.post(app.API.relations, { action, user: userId })
    .catch(rewind(user, currentStatus))
  }

  const rewind = (user, currentStatus) => err => {
    user.set('status', currentStatus)
    log_.error(err, 'action')
    throw err
  }

  const refreshNotificationsCounter = () => {
    return app.request('refresh:relations')
    .then(() => app.vent.trigger('network:requests:update'))
  }

  const API = {
    sendRequest (user) { return action(user, 'request', 'userRequested') },
    cancelRequest (user) { return action(user, 'cancel', 'public') },
    acceptRequest (user) {
      action(user, 'accept', 'friends')
      .then(refreshNotificationsCounter)

      const [ , userId ] = normalizeUser(user)
      // Refresh to get the updated data
      return app.request('get:user:model', userId, true)
    },
    discardRequest (user) {
      return action(user, 'discard', 'public')
      .then(refreshNotificationsCounter)
    },

    unfriend (user) {
      [ user ] = normalizeUser(user)
      return action(user, 'unfriend', 'public')
    },
  }

  const normalizeUser = user => {
    if (!isModel(user)) {
      throw new Error('exepected a user Model, got', user)
    }

    if (user.id != null) {
      return [ user, user.id ]
    } else {
      throw new Error('user missing id', user)
    }
  }

  app.reqres.setHandlers({
    'request:send': API.sendRequest,
    'request:cancel': API.cancelRequest,
    'request:accept': API.acceptRequest,
    'request:discard': API.discardRequest,
    unfriend: API.unfriend,
  })
}
