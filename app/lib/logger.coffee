module.exports = (_)->
  muted = require('./muted_logs')(_)
  logger =
    isMuted: (label)->
      if _.isString label
        tags = label.split ':'
        return tags.length > 1 and tags[0] in muted

    log: (obj, label, stack)->
      [obj, label] = reorderObjLabel(obj, label)
      # customizing console.log
      # unfortunatly, it makes the console loose the trace
      # of the real line and file the _.log function was called from
      # the trade-off might not be worthing it...
      if _.isString obj
        if label? then obj.logIt(label)
        else console.log obj unless (@isMuted(obj) or @isMuted(label))
      else
        unless @isMuted(label)
          console.log "===== #{label} =====" if label? and not @isMuted(label)
          console.log obj
          console.log "-----" if label?

      # log a stack trace if stack option is true
      if stack
        console.log "#{label} stack", new Error('fake error').stack.split("\n")

      return obj

    error: (err, label)->
      [err, label] = reorderObjLabel(err, label)
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
      console.warn('/!\\')
      @log.apply(@, args)
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
      [err, label] = reorderObjLabel(err, label)
      log = {obj: obj, label: label}
      $.post app.API.test, log

    logXhrErr: (err, label)->
      [err, label] = reorderObjLabel(err, label)
      if err?.responseText? then label = "#{err.responseText} (#{label})"
      if err?.status?
        switch err.status
          when 401 then console.warn '401', label
          when 404 then console.warn '404', label
      else console.error label, err
      return

  String::logIt = (label)->
    console.log "[#{label}] #{@toString()}" unless logger.isMuted(label)
    return @toString()

  # allow to pass the label first
  # useful when passing a function to a promise then or catch
  # -> allow to bind a label as first argument
  # doSomething.then _.log.bind(_, 'doing something')
  reorderObjLabel = (obj, label)->
    if label? and _.isString(obj) and not _.isString(label)
      return [label, obj]
    else
      return [obj, label]


  return logger