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
      _.log path, "#{action} path:"
      return _.preq.get path

  API =
    sendRequest: (user)->
      _.log user.get('username'), 'sendRequest'
      [user, userId] = normalizeUser user
      user.set 'status', 'userRequests'
      server.request(userId)

    cancelRequest: (user)->
      _.log user.get('username'), 'cancelRequest'
      [user, userId] = normalizeUser user
      user.set 'status', 'public'
      server.cancel(userId)

    acceptRequest: (user)->
      _.log user.get('username'), 'acceptRequest'
      [user, userId] = normalizeUser user
      user.set 'status', 'friends'
      server.accept(userId)

    discardRequest: (user)->
      _.log user.get('username'), 'discardRequest'
      [user, userId] = normalizeUser user
      user.set 'status', 'public'
      server.discard(userId)

    unfriend: (user)->
      _.log user.get('username'), 'unfriend'
      [user, userId] = normalizeUser user
      user.set 'status', 'public'
      server.unfriend(userId)

  normalizeUser = (user)->
    if _.isModel(user)
      if user.id? then return [user, user.id]
      else throw new Error('user missing id', user)
    else throw new Error('exepected a user Model, got', user)

  return reqresHandlers =
    'request:send': API.sendRequest
    'request:cancel': API.cancelRequest
    'request:accept': API.acceptRequest
    'request:discard': API.discardRequest
    'unfriend': API.unfriend
