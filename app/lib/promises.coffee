window.Promise or= require 'promise-polyfill'
{ reportError } = requireProxy 'lib/reports'

methods = {}

# Mimicking Bluebird utils
Promise.try = (fn)->
  Promise.resolve()
  .then fn

Promise.props = (obj)->
  keys = []
  values = []
  for key, value of obj
    keys.push key
    values.push value

  Promise.all values
  .then (res)->
    resultObj = {}
    res.forEach (valRes, index)->
      key = keys[index]
      resultObj[key] = valRes
    return resultObj

methods.spread = (fn)-> @then (res)=> fn.apply @, res

arrayMethod = (methodName, canReturnPromises)-> (args...)->
  @then (res)->
    _.type res, 'array'
    Promise.all res
    .then (resolvedRes)->
      finalRes = resolvedRes[methodName].apply resolvedRes, args
      if canReturnPromises then return Promise.all finalRes
      else return finalRes

methods.filter = arrayMethod 'filter'
methods.map = arrayMethod 'map', true
methods.reduce = arrayMethod 'reduce'

methods.get = (attribute)-> @then (res)-> res[attribute]

methods.tap = (fn)->
  @then (res)->
    Promise.try -> fn res
    .then -> res

methods.finally = (fn)->
  alreadyCalled = false
  @
  .then (res)->
    Promise.try ->
      alreadyCalled = true
      return fn()
    .then -> res
  .catch (err)->
    if alreadyCalled then throw err
    Promise.try -> fn()
    .then -> throw err

methods.delay = (ms)->
  promise = @
  return new Promise (resolve, reject)->
    promise
    .then (res)-> setTimeout resolve.bind(null, res), ms
    .catch reject

methods.timeout = (ms)->
  promise = @
  return new Promise (resolve, reject)->
    fulfilled = false
    expired = false

    check = ->
      if fulfilled then return
      expired = true
      # Mimicking Bluebird errors
      err = new Error 'operation timed out'
      err.name = 'TimeoutError'
      reject err

    setTimeout check, ms

    promise
    .then (res)->
      if expired then return
      fulfilled = true
      resolve res
    .catch (err)->
      if expired then return
      fulfilled = true
      reject err

for name, fn of methods
  # Some of those functions might already be implemented
  # - finally
  unless Promise.prototype[name]?
    # Make the new methods non-enumerable
    Object.defineProperty(Promise.prototype, name, { value: fn, enumerable: false })

Promise.getResolved = -> Promise.resolve()

module.exports = Promise

# Isn't defined in test environment
if window.addEventListener?
  # see http://2ality.com/2016/04/unhandled-rejections.html
  window.addEventListener 'unhandledrejection', (event)->
    console.error 'PossiblyUnhandledRejection', event
    err = new Error "PossiblyUnhandledRejection: #{event.reason}"
    reportError err
