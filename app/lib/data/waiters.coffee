waitersNames = [
  'user'
  'users'
  'groups'
  'transactions'
  'i18n'
  'layout'
]
pendingWaiters = {}
waitersPromises = {}

initWaiter = (name)->
  promise = new Promise (resolve, reject)->
    # Store the resolve and reject functions to call
    # them from waiter:resolve and waiter:reject commands
    pendingWaiters[name] =
      resolve: resolve
      reject: reject

  waitersPromises[name] = promise

module.exports = ->
  # using forEach to limit the scope of the name variable
  waitersNames.forEach initWaiter

  _waitForNetwork = ->
    return Promise.all [
      waitersPromises.user
      waitersPromises.users
      waitersPromises.groups
    ]

  app.reqres.setHandlers
    'waitForNetwork': _.once _waitForNetwork
    'wait:for': (name)-> waitersPromises[name]

  app.commands.setHandlers
    'waiter:resolve': resolve
    'waiter:reject': reject

  check = ->
    for key, promise of waitersPromises
      if promise.isPending()
        _.warn "#{key} data waiter is still pending"

  setTimeout check, 5000

resolve = (name, args...)->
  waiter = getWaiter name
  waiter.resolve.apply waiter, args
  return

reject = (name, err)->
  waiter = getWaiter name
  waiter.reject err
  _.error err, "#{name} data waiter was rejected"
  return

getWaiter = (name)->
  waiter = pendingWaiters[name]
  unless waiter? then throw new Error("unknown waiter: #{name}")
  return waiter
