const { reportError } = requireProxy('lib/reports')

// allow to pass a csle object so that we can pass whatever we want in tests
export default function (_, csle) {
  if (!csle) { csle = window.console }

  const log = function (obj, label) {
    // customizing console.log
    // unfortunatly, it makes the console loose the trace
    // of the real line and file the _.log function was called from
    // the trade-off might not be worthing it...
    if (_.isString(obj)) {
      if (label != null) {
        csle.log(`[${label}] ${obj}`)
      } else { csle.log(obj) }
    } else {
      // logging arguments as arrays for readability
      if (_.isArguments(obj)) { obj = _.toArray(obj) }
      if (label != null) { csle.log(`===== ${label} =====`) }
      csle.log(obj)
      if (label != null) { csle.log('-----') }
    }

    return obj
  }

  const error = function (err, label) {
    if (!(err instanceof Error)) {
      const errData = err
      err = new Error('invalid error object')
      err.context = errData
      // Non-standard convention: 599 = client implementation error
      err.statusCode = 599
      reportError(err)
      throw err
    }

    if (err.hasBeenLogged) { return }
    err.hasBeenLogged = true

    const originalErr = err

    let userError = false
    let serverError = false
    if (err.statusCode != null) {
      if (/^4\d+$/.test(err.statusCode)) { userError = true }
      if (/^5\d+$/.test(err.statusCode)) { serverError = true }
    }

    // No need to report user errors to the server
    // This statusCode can be set from the client for this purpose
    // of not reporting the error to the server
    if (userError) {
      return csle.error(`[${err.statusCode}][${label}] ${err.message}]`)
    }

    // No need to report server error back to the server
    if (!serverError) { reportError(err) }

    csle.error(`[${label}]\n`, err, err.context)
    return reportError(err)
  }

  // providing a custom warn as it might be used
  // by methods shared with the server
  const warn = function (...args) {
    csle.warn('/!\\')
    loggers.log.apply(null, args)
  }

  // inspection utils to log a label once a function is called
  const spy = function (res, label) {
    console.log(label)
    return res
  }

  const PartialLogger = logger => label => obj => logger(obj, label)

  const partialLoggers = {
    Log: PartialLogger(log),
    Error: PartialLogger(error),
    Warn: PartialLogger(warn),
    Spy: PartialLogger(spy),
    ErrorRethrow (label) {
      let fn
      return fn = function (err) {
        error(err, label)
        throw err
      }
    }
  }

  var loggers = {
    log,
    error,
    warn,
    spy,

    logAllEvents (obj, prefix = 'logAllEvents') {
      return obj.on('all', function (event) {
        csle.log(`[${prefix}:${event}]`)
        csle.log(arguments)
        return csle.log('---')
      })
    },

    logArgs (args) {
      csle.log('[arguments]')
      csle.log(args)
      return csle.log('---')
    },

    logServer (obj, label) {
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

  const proxied = {
    trace: csle.trace.bind(csle),
    time: csle.time.bind(csle),
    timeEnd: csle.timeEnd.bind(csle)
  }

  return _.extend(loggers, partialLoggers, proxied)
};
