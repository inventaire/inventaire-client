if (!window.Promise) { window.Promise = require('promise-polyfill') }
require('./promise_rejection_events_polyfill')()
const { reportError } = requireProxy('lib/reports')

const methods = {}

// Mimicking Bluebird utils
Promise.try = fn => Promise.resolve()
.then(fn)

Promise.props = function (obj) {
  let key
  const keys = []
  const values = []
  for (key in obj) {
    const value = obj[key]
    keys.push(key)
    values.push(value)
  }

  return Promise.all(values)
  .then(res => {
    const resultObj = {}
    res.forEach((valRes, index) => {
      key = keys[index]
      return resultObj[key] = valRes
    })
    return resultObj
  })
}

methods.spread = function (fn) { return this.then(res => fn.apply(this, res)) }

const arrayMethod = (methodName, canReturnPromises) => function (...args) {
  return this.then(res => {
    _.type(res, 'array')
    return Promise.all(res)
    .then(resolvedRes => {
      const finalRes = resolvedRes[methodName].apply(resolvedRes, args)
      if (canReturnPromises) {
        return Promise.all(finalRes)
      } else { return finalRes }
    })
  })
}

methods.filter = arrayMethod('filter')
methods.map = arrayMethod('map', true)
methods.reduce = arrayMethod('reduce')

methods.get = function (attribute) { return this.then(res => res[attribute]) }

methods.tap = function (fn) {
  return this.then(res => Promise.try(() => fn(res))
  .then(() => res))
}

methods.finally = function (fn) {
  let alreadyCalled = false
  return this
  .then(res => Promise.try(() => {
    alreadyCalled = true
    return fn()
  }).then(() => res)).catch(err => {
    if (alreadyCalled) { throw err }
    return Promise.try(() => fn())
    .then(() => { throw err })
  })
}

methods.delay = function (ms) {
  const promise = this
  return new Promise((resolve, reject) => promise
  .then(res => setTimeout(resolve.bind(null, res), ms))
  .catch(reject))
}

methods.timeout = function (ms) {
  const promise = this
  return new Promise((resolve, reject) => {
    let fulfilled = false
    let expired = false

    const check = function () {
      if (fulfilled) { return }
      expired = true
      // Mimicking Bluebird errors
      const err = new Error('operation timed out')
      err.name = 'TimeoutError'
      return reject(err)
    }

    setTimeout(check, ms)

    return promise
    .then(res => {
      if (expired) { return }
      fulfilled = true
      return resolve(res)
    }).catch(err => {
      if (expired) { return }
      fulfilled = true
      return reject(err)
    })
  })
}

for (const name in methods) {
  // Some of those functions might already be implemented
  // - finally
  const fn = methods[name]
  if (Promise.prototype[name] == null) {
    // Make the new methods non-enumerable
    Object.defineProperty(Promise.prototype, name, { value: fn, enumerable: false })
  }
}

Promise.getResolved = () => Promise.resolve()

export default Promise

// Isn't defined in test environment
if (window.addEventListener != null) {
  // see http://2ality.com/2016/04/unhandled-rejections.html
  window.addEventListener('unhandledrejection', event => {
    const err = event.reason
    console.error('PossiblyUnhandledRejection', err, err.context)
    return reportError(err)
  })
}
