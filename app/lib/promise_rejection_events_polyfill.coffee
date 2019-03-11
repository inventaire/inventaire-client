# Based on https://github.com/ruodoo/odoo/blob/27d25b5315808dca946c609b5ebf4ca123772b64/addons/web/static/lib/unhandled-rejection-polyfill/unhandled-rejection-polyfill.js

OriginalPromise = window.Promise

dispatchUnhandledRejectionEvent = (promise, reason)->
  event = document.createEvent 'Event'
  Object.defineProperties event,
    promise: { value: promise, writable: false }
    reason: { value: reason, writable: false }
  event.initEvent 'unhandledrejection', false, true
  window.dispatchEvent event

patchedPromise = (resolver)->
  unless @ instanceof patchedPromise
    throw new TypeError 'Cannot call a class as a function'

  promise = new OriginalPromise (resolve, reject)->
    customReject = (reason)->
      # macro-task (setTimeout) will execute after micro-task (promise)
      fn = -> unless promise.handled then dispatchUnhandledRejectionEvent promise, reason
      setTimeout fn, 0
      reject reason

    try return resolver resolve, customReject
    catch err then return customReject err

  promise.__proto__ = patchedPromise.prototype
  return promise

patchedPromise.__proto__ = OriginalPromise
patchedPromise::__proto__ = OriginalPromise.prototype

setHandledAndReject = (reject)->
  unless reject? then return
  return (reason)=>
    @handled = true
    reject reason

patchedPromise::then = (resolve, reject)->
  OriginalPromise::then.call @, resolve, setHandledAndReject.call(@, reject)

patchedPromise::catch = (reject)->
  OriginalPromise::catch.call @, setHandledAndReject.call(@, reject)

module.exports = ->
  if typeof PromiseRejectionEvent is 'undefined'
    window.Promise = patchedPromise
