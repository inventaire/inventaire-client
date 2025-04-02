import { commands, reqres } from '#app/radio'

// Some data (as little as possible) is fetched at every page load,
// this module handles returning promises on request corresponding
// to those global data elements being ready
const waitersNames = [
  'i18n',
  'layout',
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

  reqres.setHandlers({
    'wait:for': name => waitersPromises[name],
  })

  commands.setHandlers({
    'waiter:resolve': resolve,
  })
}

const resolve = (name, ...args) => {
  const waiter = getWaiter(name)
  waiter.resolve(...args)
}

const getWaiter = name => {
  const waiter = pendingWaiters[name]
  if (waiter == null) throw new Error(`unknown waiter: ${name}`)
  return waiter
}
