import Radio from 'backbone.radio'
import { newError, serverReportError } from '#app/lib/error'
import { assertFunction, assertString } from './lib/assert_types'
import { objectEntries } from './lib/utils'

export const channel = Radio.channel('global')

export const reqres = {
  setHandlers (obj) {
    for (const [ key, callback ] of objectEntries(obj)) {
      assertString(key)
      assertFunction(callback)
      channel.reply(key, callback)
    }
  },
}

export function request (handlerKey, ...args) {
  // @ts-expect-error
  if (channel._requests == null) {
    throw newError('radio request called before before handlers were set', 500, { handlerKey, args })
  }
  // Prevent silent errors when a handler is called but hasn't been defined yet
  // @ts-expect-error "Property '_requests' does not exist on type 'Channel'": _requests is a pseudo-private attribute
  if (channel._requests[handlerKey] == null) {
    // Not throwing to let a chance to the client to do without it
    // In case of a 'request', the absence of returned value is likely to make it crash later though
    serverReportError(`radio request "${handlerKey}" isn't defined`)
  } else {
    return channel.request(handlerKey, ...args)
  }
}

export function execute (...args) {
  // Like request but not returning anyting
  // @ts-expect-error Silencing the type error until we can find a better solution
  request(...args)
}
