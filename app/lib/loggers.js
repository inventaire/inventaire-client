import { reportError } from 'lib/reports'

const log = (obj, label) => {
  // customizing console.log
  // unfortunatly, it makes the console loose the trace
  // of the real line and file the log_.info function was called from
  // the trade-off might not be worthing it...
  if (_.isString(obj)) {
    if (label != null) console.log(`[${label}] ${obj}`)
    else console.log(obj)
  } else {
    // logging arguments as arrays for readability
    if (_.isArguments(obj)) obj = Array.from(obj)
    if (label != null) console.log(`===== ${label} =====`)
    console.log(obj)
    if (label != null) console.log('-----')
  }

  return obj
}

const error = (err, label) => {
  if (!(err instanceof Error)) {
    const errData = err
    err = new Error('invalid error object')
    err.context = errData
    // Non-standard convention: 599 = client implementation error
    err.statusCode = 599
    reportError(err)
    throw err
  }

  if (err.hasBeenLogged) return
  err.hasBeenLogged = true

  let userError = false
  if (err.statusCode != null) {
    if (/^4\d+$/.test(err.statusCode)) userError = true
  }

  // No need to report user errors to the server
  // This statusCode can be set from the client for this purpose
  // of not reporting the error to the server
  if (userError) {
    return console.error(`[${err.statusCode}][${label}] ${err.message}]`)
  }

  // No need to report server error back to the server
  if (!err.serverError) reportError(err)
  console.error(`[${label}]\n`, err.message, err.stack, err, err.context)
}

// providing a custom warn as it might be used
// by methods shared with the server
const warn = (...args) => {
  console.warn('/!\\')
  loggers.log.apply(null, args)
}

// inspection utils to log a label once a function is called
const spy = (res, label) => {
  console.log(label)
  return res
}

const PartialLogger = logger => label => obj => logger(obj, label)

const partialLoggers = {
  Info: PartialLogger(log),
  Error: PartialLogger(error),
  Warn: PartialLogger(warn),
  ErrorRethrow: label => err => {
    error(err, label)
    throw err
  }
}

const loggers = {
  info: log,
  error,
  warn,
  spy,

  logServer: (obj, label) => {
    // Using jQuery promise instead of preq to be able to report errors
    // happening before preq is initialized
    $.post({
      url: app.API.tests,
      // jquery defaults to x-www-form-urlencoded
      headers: { 'content-type': 'application/json' },
      data: JSON.stringify({ obj, label })
    })
    return obj
  }
}

export default _.extend(loggers, partialLoggers)
