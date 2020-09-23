export default function (app, _) {
  const action = function (user, action, newStatus, label) {
    let userId;
    [ user, userId ] = Array.from(normalizeUser(user))
    const currentStatus = user.get('status')
    user.set('status', newStatus)

    return _.preq.post(app.API.relations, { action, user: userId })
    .catch(rewind(user, currentStatus, 'action err'))
  }

  var rewind = (user, currentStatus, label) => function (err) {
    user.set('status', currentStatus)
    _.error(err, 'action')
    throw err
  }

  const refreshNotificationsCounter = () => app.request('refresh:relations')
  .then(() => app.vent.trigger('network:requests:update'))

  const API = {
    sendRequest (user) { return action(user, 'request', 'userRequested') },
    cancelRequest (user) { return action(user, 'cancel', 'public') },
    acceptRequest (user, showUserInventory = true) {
      let userId
      action(user, 'accept', 'friends')
      .then(refreshNotificationsCounter);

      [ user, userId ] = Array.from(normalizeUser(user))
      // Refresh to get the updated data
      return app.request('get:user:model', userId, true)
      .then(() => { if (showUserInventory) { return app.execute('show:inventory:user', user) } })
    },
    discardRequest (user) {
      return action(user, 'discard', 'public')
      .then(refreshNotificationsCounter)
    },

    unfriend (user) {
      let userId;
      [ user, userId ] = Array.from(normalizeUser(user))
      return action(user, 'unfriend', 'public')
    }
  }

  var normalizeUser = function (user) {
    if (!_.isModel(user)) {
      throw new Error('exepected a user Model, got', user)
    }

    if (user.id != null) {
      return [ user, user.id ]
    } else { throw new Error('user missing id', user) }
  }

  app.reqres.setHandlers({
    'request:send': API.sendRequest,
    'request:cancel': API.cancelRequest,
    'request:accept': API.acceptRequest,
    'request:discard': API.discardRequest,
    unfriend: API.unfriend
  })
};
