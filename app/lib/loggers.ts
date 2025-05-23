import { isString, isArguments } from 'underscore'
import { reportError } from '#app/lib/reports'

const log = (obj, label?) => {
  // customizing console.log
  // unfortunatly, it makes the console loose the trace
  // of the real line and file the log_.info function was called from
  // the trade-off might not be worthing it...
  if (isString(obj)) {
    if (label != null) console.log(`[${label}] ${obj}`)
    else console.log(obj)
  } else {
    // logging arguments as arrays for readability
    if (isArguments(obj)) obj = Array.from(obj)
    if (label != null) console.log(`===== ${label} =====`)
    console.log(obj)
    if (label != null) console.log('-----')
  }

  return obj
}

const error = (err, label?) => {
  // The previous 'err instanceof Error' now fails
  // as it seems that instances of TypeError aren't considered
  // instances of Error anymore
  if (!(err.constructor?.name?.endsWith('Error'))) {
    const errData = err
    err = new Error('invalid error object')
    err.context = errData
    // Non-standard convention: 599 = client implementation error
    err.statusCode = 599
    reportError(err)
    throw err
  }

  let userError = false
  if (err.statusCode != null) {
    if (/^4\d+$/.test(err.statusCode)) userError = true
  }

  // No need to report user errors to the server
  // This statusCode can be set from the client for this purpose
  // of not reporting the error to the server
  if (userError) {
    return console.error(`[${err.statusCode}]${label ? `[${label}]` : ''} ${err.message}`)
  }

  // No need to report server error back to the server
  if (!err.serverError) reportError(err)

  const loggerArgs = []
  if (label) loggerArgs.push(`[${label}]\n`)
  loggerArgs.push(err)
  if (err.context) loggerArgs.push(err.context)
  console.error(...loggerArgs)
}

const warn = (obj, label?) => {
  console.warn('/!\\')
  log(obj, label)
}

const PartialLogger = logger => label => obj => logger(obj, label)

export const log_ = {
  info: log,
  error,
  warn,
  logServer: (obj, label) => {
    // Using native fetch promise instead of preq to be able to report errors
    // happening before preq is initialized
    // Not import #app/api/api.ts API.tests to avoid depending on the app object in tests env
    fetch('/api/tests', {
      method: 'post',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify({ obj, label }),
    })
    return obj
  },

  Info: PartialLogger(log),
  Error: PartialLogger(error),
  Warn: PartialLogger(warn),
  ErrorRethrow: label => err => {
    error(err, label)
    throw err
  },
}

export default log_
