module.exports = (app, _)->
  server =
    request: (userId)-> @base 'request', userId
    cancel: (userId)-> @base 'cancel', userId
    accept: (userId)-> @base 'accept', userId
    discard: (userId)-> @base 'discard', userId
    unfriend: (userId)-> @base 'unfriend', userId
    base: (action, userId)->
      path = _.buildPath '/api/relations',
        action: action
        user: userId
      return _.preq.get(path)
      .catch (err)-> _.logXhrErr err, 'relations action err'

  action = (user, action, newStatus, label)->
    [user, userId] = normalizeUser user
    user.set 'status', newStatus
    server[action](userId)

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
