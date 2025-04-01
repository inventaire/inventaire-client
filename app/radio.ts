import { publish, subscribe } from '@jgarber/radioradio'
import { serverReportError } from '#app/lib/error'

export const channel = {
  on: subscribe,
  trigger: publish,
}

type ReqResHandlers = Record<string, (...args) => unknown>
const reqresHandlers: ReqResHandlers = {}

export const reqres = {
  setHandlers (handlers: ReqResHandlers) {
    Object.assign(reqresHandlers, handlers)
  },
}

export function request (handlerKey: string, ...args: unknown[]) {
  // Prevent silent errors when a handler is called but hasn't been defined yet
  if (reqresHandlers[handlerKey] == null) {
    // Not throwing to let a chance to the client to do without it
    // In case of a 'request', the absence of returned value is likely to make it crash later though
    serverReportError(`radio request "${handlerKey}" isn't defined`)
  } else {
    return reqresHandlers[handlerKey](...args)
  }
}

export function execute (handlerKey: string, ...args: unknown[]) {
  // Like request but not returning anyting
  request(handlerKey, ...args)
}
