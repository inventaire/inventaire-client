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
      userId = normalizeUser user
      addTo 'userRequests', userId
      server.request(userId)

    cancelRequest: (user)->
      userId = normalizeUser user
      removeFrom 'userRequests', userId
      server.cancel(userId)

    acceptRequest: (user)->
      userId = normalizeUser user
      addTo 'friends', userId
      removeFrom 'othersRequests', userId
      server.accept(userId)

    discardRequest: (user)->
      userId = normalizeUser user
      removeFrom 'othersRequests', userId
      server.discard(userId)

    unfriend: (user)->
      userId = normalizeUser user
      removeFrom 'friends', userId
      server.remove(userId)

  addTo = (relation, userId)->
    app.user.push "relations.#{relation}", userId

  removeFrom = (relation, userId)->
    app.user.without "relations.#{relation}", userId

  normalizeUser = (user)->
    if _.isString(user) then return user
    else
      if user.id? then return user.id
      else throw new Error('user missing id', user)

  return reqresHandlers =
    'request:send': API.sendRequest
    'request:cancel': API.cancelRequest
    'request:accept': API.acceptRequest
    'request:discard': API.acceptRequest
    'unfriend': API.unfriend
