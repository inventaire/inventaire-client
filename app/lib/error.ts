import { isNumber, isArguments } from 'underscore'
import log_ from '#app/lib/loggers'

export type ErrorContext = object | Record<string, unknown> | string[]

export interface ContextualizedError extends Error {
  code?: string
  context?: ErrorContext
  i18n?: string | boolean
  selector?: unknown
  timestamp?: string
  serverError?: boolean
  html?: string
  // Request error
  statusCode?: number
  statusText?: string
  responseText?: string
  responseJSON?: Record<string, unknown>
}

export function newError (message: string, statusCode?: number | ErrorContext, context?: ErrorContext) {
  // Accept a type Context as second argument type for legacy reasons
  // If statusCode is not an number, then it is a context,
  // statusCode is then set to 599: client implementation errors
  if (!isNumber(statusCode)) {
    [ statusCode, context ] = [ 599, statusCode ]
  }

  const err = new Error(message) as ContextualizedError
  // Set statusCode to a 4xx error for user errors, to prevent unnecessary
  // reporting to the server:
  // ie. do not open an issue everytime a password is mistyped
  err.statusCode = statusCode

  // converting arguments object to array for readability in logs
  if (isArguments(context)) context = Array.from(context)
  err.context = context
  err.timestamp = new Date().toISOString()

  return err
}

// Log and report formatted errors to the server, without throwing
export function serverReportError (message, context: ErrorContext = {}, statusCode = 599) {
  try {
    if (context) context = deepClone(context)
    // @ts-expect-error
    context.location = location.href
  } catch (err) {
    console.error(err)
  }
  // Non-standard convention
  // 599 = client implementation error
  // 598 = suspected user abuse or spam account
  const err = newError(message, statusCode, context)
  log_.error(err, `[reported error (not thrown)] ${message}`)
}

// Do not use lib/utils deepClone to prevent circular dependency
const deepClone = obj => JSON.parse(JSON.stringify(obj))

// Legacy functions

export function formatError (err, selector, i18n?) {
  if (err.i18n == null) err.i18n = i18n !== false
  err.selector = selector
  return err
}

export function formatAndThrowError (selector, i18n?) {
  return function (err) {
    throw formatError(err, selector, i18n)
  }
}
