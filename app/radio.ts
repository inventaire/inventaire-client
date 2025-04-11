import { without } from 'underscore'
import { newError, serverReportError, type ErrorContext } from './lib/error'
import log_ from './lib/loggers'

type Subscriber = (...args: unknown[]) => unknown

const events: Record<string, Subscriber[]> = {}

export async function trigger (eventName: string, data?: unknown) {
  if (!(eventName in events)) return logError('event not found', { eventName, data })
  for (const subscriber of events[eventName]) {
    try {
      await subscriber(data)
    } catch (err) {
      err.context ??= {}
      err.context.eventName = eventName
      log_.error(err, 'event subscriber failed')
    }
  }
}

export function subscribe (eventName: string, subscriber: Subscriber) {
  events[eventName] ??= []
  events[eventName].push(subscriber)
}

export function unsubscribe (eventName: string, subscriber: Subscriber) {
  if (!events[eventName].includes(subscriber)) {
    return logError('subscriber not found', { eventName, subscriber, subscribers: events[eventName] })
  }
  events[eventName] = without(events[eventName], subscriber)
}

function logError (message: string, context: ErrorContext) {
  const err = newError(message, 500, context)
  log_.error(err)
}

// Mapping API to the formerly used backbone-wreqr concepts
export const vent = {
  on: subscribe,
  off: unsubscribe,
  trigger,
  Trigger: (eventName: string) => trigger.bind(null, eventName),
}

type ReqResHandlers = Record<string, (...args) => unknown>
const reqresHandlers: ReqResHandlers = {}

function setHandlers (handlers: ReqResHandlers) {
  Object.assign(reqresHandlers, handlers)
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

export const reqres = {
  setHandlers,
  request,
}

export const commands = {
  setHandlers,
  execute,
  Execute: key => request.bind(null, key),
}
