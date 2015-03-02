module.exports = (_)->
  loggers_ = sharedLib('loggers')(_)
  muted = require('./muted_logs')(_)

  isMuted = (label)->
    if _.isString label
      tags = label.split ':'
      return tags.length > 1 and tags[0] in muted

  log = (obj, label, stack)->
    [obj, label] = loggers_.reorderObjLabel(obj, label)
    # customizing console.log
    # unfortunatly, it makes the console loose the trace
    # of the real line and file the _.log function was called from
    # the trade-off might not be worthing it...
    if _.isString obj
      if label? then obj.logIt(label)
      else console.log obj unless (isMuted(obj) or isMuted(label))
    else
      unless isMuted(label)
        console.log "===== #{label} =====" if label? and not isMuted(label)
        console.log obj
        console.log "-----" if label?

    # log a stack trace if stack option is true
    if stack
      console.log "#{label} stack", new Error('fake error').stack.split("\n")

    return obj

  logXhrErr = (err, label)->
    [err, label] = loggers_.reorderObjLabel(err, label)
    if err?.responseText? then label = "#{err.responseText} (#{label})"
    if err?.status?
      switch err.status
        when 401 then console.warn '401', label
        when 404 then console.warn '404', label
    else console.error label, err
    return

  bindingLoggers =
    Log: (label)-> loggers_.bindLabel log, label
    LogXhrErr: (label)-> loggers_.bindLabel logXhrErr, label

  loggers =
    isMuted: isMuted
    log: log
    logXhrErr: logXhrErr
    error: (err, label)->
      [err, label] = loggers_.reorderObjLabel(err, label)
      unless err?.stack?
        label or= 'empty error'
        newErr = new Error(label)
        report = [err, newErr.message, newErr.stack?.split('\n')]
      else
        report = [err.message or err, err.stack?.split('\n')]
      window.reportErr {error: report}
      console.error.apply console, report

    # providing a custom warn as it might be used
    # by methods shared with the server
    warn: (args...)->
      console.warn '/!\\'
      loggers.log.apply null, args
      return

    logAllEvents: (obj, prefix='logAllEvents')->
      obj.on 'all', (event)->
        console.log "[#{prefix}:#{event}]"
        console.log arguments
        console.log '---'

    logArgs: (args)->
      console.log "[arguments]"
      console.log args
      console.log '---'

    logServer: (obj, label)->
      [err, label] = loggers_.reorderObjLabel(err, label)
      log = {obj: obj, label: label}
      $.post app.API.test, log

  String::logIt = (label)->
    console.log "[#{label}] #{@toString()}" unless isMuted(label)
    return @toString()



  return _.extend loggers, bindingLoggers
