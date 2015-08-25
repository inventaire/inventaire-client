module.exports = (app, _)->
  server =
    request: (userId)-> @base 'request', userId
    cancel: (userId)-> @base 'cancel', userId
    accept: (userId)-> @base 'accept', userId
    discard: (userId)-> @base 'discard', userId
    unfriend: (userId)-> @base 'unfriend', userId
    base: (action, userId)->
      _.preq.post app.API.relations,
        action: action
        user: userId

  action = (user, action, newStatus, label)->
    [user, userId] = normalizeUser user
    currentStatus = user.get 'status'
    user.set 'status', newStatus
    server[action](userId)
    .catch Rewind(user, currentStatus, 'action err')

  Rewind = (user, currentStatus, label)->
    handler = (err)->
      user.set 'status', currentStatus
      _.error err, 'action'

  API =
    sendRequest: (user)-> action user, 'request', 'userRequested'
    cancelRequest: (user)-> action user, 'cancel', 'public'
    acceptRequest: (user)->
      action user, 'accept', 'friends'
      app.execute 'show:inventory:user', user
    discardRequest: (user)-> action user, 'discard', 'public'
    unfriend: (user)->
      [user, userId] = normalizeUser user
      app.execute 'inventory:remove:user:items', userId
      action user, 'unfriend', 'public'

  normalizeUser = (user)->
    unless _.isModel(user)
      throw new Error('exepected a user Model, got', user)

    if user.id? then return [user, user.id]
    else throw new Error('user missing id', user)

  return reqresHandlers =
    'request:send': API.sendRequest
    'request:cancel': API.cancelRequest
    'request:accept': API.acceptRequest
    'request:discard': API.discardRequest
    'unfriend': API.unfriend
