# Some data (as little as possible) is fetched at every page load,
# this module handles returning promises on request corresponding
# to those global data elements being ready

waitersNames = [
  'user'
  'relations'
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
    pendingWaiters[name] = { resolve, reject }

  waitersPromises[name] = promise

module.exports = ->
  # using forEach to limit the scope of the name variable
  waitersNames.forEach initWaiter

  _waitForNetwork = ->
    return Promise.all [
      waitersPromises.user
      waitersPromises.relations
      waitersPromises.groups
    ]

  app.reqres.setHandlers
    'waitForNetwork': _.once _waitForNetwork
    'wait:for': (name)-> waitersPromises[name]

  app.commands.setHandlers
    'waiter:resolve': resolve
    'waiter:reject': reject

  # TODO: re-implement the check without promise.isPending
  # as it was part of Bluebird, which was replaced by a lighter implementation

  # check = ->
  #   for key, promise of waitersPromises
      # if promise.isPending()
      #   _.warn "#{key} data waiter is still pending"

  # setTimeout check, 5000

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
