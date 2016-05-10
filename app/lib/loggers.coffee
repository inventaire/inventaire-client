# allow to pass a csle object so that we can pass whatever we want in tests
module.exports = (_, csle)->
  csle or= window.console

  log = (obj, label, stack)->
    # customizing console.log
    # unfortunatly, it makes the console loose the trace
    # of the real line and file the _.log function was called from
    # the trade-off might not be worthing it...
    if _.isString obj
      if label? then csle.log "[#{label}] #{obj}"
      else csle.log obj
    else
      # logging arguments as arrays for readability
      if _.isArguments obj then obj = _.toArray obj
      csle.log "===== #{label} =====" if label?
      csle.log obj
      csle.log "-----" if label?

    # Log a stack trace if stack option is true.
    # Testing console.trace? as not all browsers have this function
    if stack then console.trace?()

    return obj

  error = (err, label)->
    if err?.status?
      switch err.status
        when 401 then return csle.warn '401', label
        when 404 then return csle.warn '404', label
        # else it will be treated as other errors

    unless err?.stack?
      label or= 'empty error'
      newErr = new Error(label)
      stackLines = newErr.stack?.split('\n')
      report = [err, newErr.message, stackLines]
    else
      stackLines = err.stack?.split('\n')
      report = [err.message or err, stackLines]

    if err?.context? then report.push err.context

    report.push label

    window.reportErr {error: report}

    prettyLog = "===== #{label} =====\n"
    if err?.responseText? then prettyLog += "\n#{err.responseText}\n\n"
    csle.error prettyLog, stackLines, "\n-----"

  # providing a custom warn as it might be used
  # by methods shared with the server
  warn = (args...)->
    csle.warn '/!\\'
    loggers.log.apply null, args
    return

  # inspection utils to log a label once a function is called
  spy = (res, label)->
    console.log label
    return res

  PartialLogger = (logger)-> (label)-> (obj)-> logger obj, label

  partialLoggers =
    Log: PartialLogger log
    Error: PartialLogger error
    Warn: PartialLogger warn
    Spy: PartialLogger spy
    ErrorRethrow: (label)->
      return fn = (err)->
        error err, label
        throw err

  loggers =
    log: log
    error: error
    warn: warn
    spy: spy


    logAllEvents: (obj, prefix='logAllEvents')->
      obj.on 'all', (event)->
        csle.log "[#{prefix}:#{event}]"
        csle.log arguments
        csle.log '---'

    logArgs: (args)->
      csle.log "[arguments]"
      csle.log args
      csle.log '---'

    logServer: (obj, label)->
      report = {obj: obj, label: label}
      $.post app.API.tests, report
      return obj

  proxied =
    trace: csle.trace.bind(csle)
    time: csle.time.bind(csle)
    timeEnd: csle.timeEnd.bind(csle)

  return _.extend loggers, partialLoggers, proxied
