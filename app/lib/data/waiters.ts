import { once } from 'underscore'
import log_ from '#app/lib/loggers'
import { commands, reqres } from '#app/radio'
// Some data (as little as possible) is fetched at every page load,
// this module handles returning promises on request corresponding
// to those global data elements being ready

const waitersNames = [
  'user',
  'relations',
  'groups',
  'transactions',
  'i18n',
  'layout',
  'topbar',
]
const pendingWaiters = {}
const waitersPromises = {}

const initWaiter = name => {
  const promise = new Promise((resolve, reject) => {
    // Store the resolve and reject functions to call
    // them from waiter:resolve and waiter:reject commands
    pendingWaiters[name] = { resolve, reject }
  })

  waitersPromises[name] = promise
}

export default () => {
  // using forEach to limit the scope of the name variable
  waitersNames.forEach(initWaiter)

  const _waitForNetwork = () => Promise.all([
    // @ts-expect-error
    waitersPromises.user,
    // @ts-expect-error
    waitersPromises.relations,
    // @ts-expect-error
    waitersPromises.groups,
  ])

  reqres.setHandlers({
    waitForNetwork: once(_waitForNetwork),
    'wait:for': name => waitersPromises[name],
  })

  commands.setHandlers({
    'waiter:resolve': resolve,
    'waiter:reject': reject,
  })
}

// TODO: re-implement the check without promise.isPending
// as it was part of Bluebird, which was replaced by a lighter implementation

// check = ->
//   for key, promise of waitersPromises
// if promise.isPending()
//   log_.warn "#{key} data waiter is still pending"

// setTimeout check, 5000

const resolve = (name, ...args) => {
  const waiter = getWaiter(name)
  waiter.resolve(...args)
}

const reject = (name, err) => {
  const waiter = getWaiter(name)
  waiter.reject(err)
  log_.error(err, `${name} data waiter was rejected`)
}

const getWaiter = name => {
  const waiter = pendingWaiters[name]
  if (waiter == null) throw new Error(`unknown waiter: ${name}`)
  return waiter
}
