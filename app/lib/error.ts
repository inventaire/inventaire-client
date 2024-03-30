import { isNumber, isArguments } from 'underscore'
import log_ from '#lib/loggers'

const formatError = function (message, statusCode, context?) {
  // Accept a statusCode number as second argument as done on the server
  // cf server/lib/error/format_error.js
  // Allows for instance to not report non-operational/user errors to the server
  // in case statusCode is a 4xx error

  // Default to client implementation errors: 599
  if (!isNumber(statusCode)) {
    [ statusCode, context ] = [ 599, statusCode ]
  }

  const err = new Error(message)
  // Set statusCode to a 4xx error for user errors to prevent it
  // to be unnecessary reported to the server:
  // We don't need to open an issue everytime miss type their password
  err.statusCode = statusCode

  // converting arguments object to array for readability in logs
  if (isArguments(context)) context = Array.from(context)
  err.context = context
  err.timestamp = new Date().toISOString()

  return err
}

const error_ = {
  new: formatError,
  // newWithSelector: use forms_.throwError instead

  complete (err, selector, i18n?) {
    if (err.i18n == null) err.i18n = i18n !== false
    err.selector = selector
    return err
  },

  // /!\ throws the error while error_.complete only returns it.
  // This difference is justified by the different use of both functions
  Complete (selector, i18n?) {
    return function (err) {
      throw error_.complete(err, selector, i18n)
    }
  },

  async reject (message, context) {
    const err = formatError(message, context)
    throw err
  },

  // Log and report formatted errors to the server, without throwing
  report (message, context = {}, statusCode = 599) {
    context = deepClone(context)
    context.location = location.href
    // Non-standard convention
    // 599 = client implementation error
    // 598 = suspected user abuse or spam account
    const err = formatError(message, statusCode, context)
    log_.error(err, `[reported error (not thrown)] ${message}`)
  },
}

// Do not use lib/utils deepClone to prevent circular dependency
const deepClone = obj => JSON.parse(JSON.stringify(obj))

export default error_
