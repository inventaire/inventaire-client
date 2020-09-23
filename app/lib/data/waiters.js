/* eslint-disable
    implicit-arrow-linebreak,
    no-return-assign,
    no-undef,
    no-var,
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
// Some data (as little as possible) is fetched at every page load,
// this module handles returning promises on request corresponding
// to those global data elements being ready

const waitersNames = [
  'user',
  'relations',
  'groups',
  'transactions',
  'i18n',
  'layout'
]
const pendingWaiters = {}
const waitersPromises = {}

const initWaiter = function (name) {
  const promise = new Promise((resolve, reject) => // Store the resolve and reject functions to call
  // them from waiter:resolve and waiter:reject commands
    pendingWaiters[name] = { resolve, reject })

  return waitersPromises[name] = promise
}

export default function () {
  // using forEach to limit the scope of the name variable
  waitersNames.forEach(initWaiter)

  const _waitForNetwork = () => Promise.all([
    waitersPromises.user,
    waitersPromises.relations,
    waitersPromises.groups
  ])

  app.reqres.setHandlers({
    waitForNetwork: _.once(_waitForNetwork),
    'wait:for' (name) { return waitersPromises[name] }
  })

  return app.commands.setHandlers({
    'waiter:resolve': resolve,
    'waiter:reject': reject
  })
};

// TODO: re-implement the check without promise.isPending
// as it was part of Bluebird, which was replaced by a lighter implementation

// check = ->
//   for key, promise of waitersPromises
// if promise.isPending()
//   _.warn "#{key} data waiter is still pending"

// setTimeout check, 5000

var resolve = function (name, ...args) {
  const waiter = getWaiter(name)
  waiter.resolve.apply(waiter, args)
}

var reject = function (name, err) {
  const waiter = getWaiter(name)
  waiter.reject(err)
  _.error(err, `${name} data waiter was rejected`)
}

var getWaiter = function (name) {
  const waiter = pendingWaiters[name]
  if (waiter == null) { throw new Error(`unknown waiter: ${name}`) }
  return waiter
}
