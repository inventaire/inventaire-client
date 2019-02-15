window.Promise or= require 'promise-polyfill'

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

Promise::spread = (fn)-> @then (res)=> fn.apply @, res

Promise::filter = (fn)-> @then (res)-> res.filter fn

Promise::map = (fn)-> @then (res)-> res.map fn

Promise::reduce = (fn, initialValue)-> @then (res)-> res.reduce fn, initialValue

Promise::get = (attribute)-> @then (res)-> res[attribute]

Promise::tap = (fn)->
  @then (res)->
    Promise.try -> fn res
    .then -> res

Promise::delay = (ms)->
  promise = @
  return new Promise (resolve, reject)->
    promise
    .then (res)-> setTimeout resolve.bind(null, res), ms
    .catch reject

Promise::timeout = (ms)->
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

# Used has a way to create only one resolved promise to start promise chains.
# This may register as a premature micro-optimization
# cf http://stackoverflow.com/q/40683818/3324977
Promise.resolved = Promise.resolve()
if Object.freeze? then Object.freeze Promise.resolved

module.exports = Promise

# Isn't defined in test environment
if window.addEventListener?
  # see http://2ality.com/2016/04/unhandled-rejections.html
  window.addEventListener 'unhandledrejection', (event)->
    console.error 'PossiblyUnhandledRejection', event
    err = new Error "PossiblyUnhandledRejection: #{event.reason}"
    reportError err
