import { isNumber, isArguments } from 'underscore'
import log_ from '#lib/loggers'

type ErrorContext = object | string[]

export interface ContextualizedError extends Error {
  code?: string
  context?: ErrorContext
  i18n?: string | boolean
  selector?: unknown
  statusCode?: number
  timestamp?: string
  serverError?: boolean
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
export function serverReportError (message, context = {}, statusCode = 599) {
  context = deepClone(context)
  context.location = location.href
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
