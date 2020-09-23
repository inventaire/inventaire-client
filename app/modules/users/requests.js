module.exports = (app, _)->
  action = (user, action, newStatus, label)->
    [ user, userId ] = normalizeUser user
    currentStatus = user.get 'status'
    user.set 'status', newStatus

    _.preq.post app.API.relations, { action, user: userId }
    .catch rewind(user, currentStatus, 'action err')

  rewind = (user, currentStatus, label)-> (err)->
    user.set 'status', currentStatus
    _.error err, 'action'
    throw err

  refreshNotificationsCounter = ->
    app.request 'refresh:relations'
    .then -> app.vent.trigger 'network:requests:update'

  API =
    sendRequest: (user)-> action user, 'request', 'userRequested'
    cancelRequest: (user)-> action user, 'cancel', 'public'
    acceptRequest: (user, showUserInventory = true)->
      action user, 'accept', 'friends'
      .then refreshNotificationsCounter

      [ user, userId ] = normalizeUser user
      # Refresh to get the updated data
      app.request 'get:user:model', userId, true
      .then -> if showUserInventory then app.execute 'show:inventory:user', user
    discardRequest: (user)->
      action user, 'discard', 'public'
      .then refreshNotificationsCounter

    unfriend: (user)->
      [ user, userId ] = normalizeUser user
      action user, 'unfriend', 'public'

  normalizeUser = (user)->
    unless _.isModel(user)
      throw new Error('exepected a user Model, got', user)

    if user.id? then return [ user, user.id ]
    else throw new Error('user missing id', user)

  app.reqres.setHandlers
    'request:send': API.sendRequest
    'request:cancel': API.cancelRequest
    'request:accept': API.acceptRequest
    'request:discard': API.discardRequest
    'unfriend': API.unfriend

  return
