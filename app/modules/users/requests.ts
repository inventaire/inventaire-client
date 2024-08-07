import { API } from '#app/api/api'
import { isModel } from '#app/lib/boolean_tests'
import { newError } from '#app/lib/error'
import log_ from '#app/lib/loggers'
import preq from '#app/lib/preq'

export default function (app) {
  const action = function (user, action, newStatus) {
    let userId;
    [ user, userId ] = normalizeUser(user)
    const currentStatus = user.get('status')
    user.set('status', newStatus)

    return preq.post(API.relations, { action, user: userId })
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

  const controller = {
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
      throw newError('exepected a user Model, got', { user })
    }

    if (user.id != null) {
      return [ user, user.id ]
    } else {
      throw newError('user missing id', { user })
    }
  }

  app.reqres.setHandlers({
    'request:send': controller.sendRequest,
    'request:cancel': controller.cancelRequest,
    'request:accept': controller.acceptRequest,
    'request:discard': controller.discardRequest,
    unfriend: controller.unfriend,
  })
}
