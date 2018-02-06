{ reportError } = require 'lib/reports'

module.exports = ->
  # override window.onerror to always log the stacktrace
  window.onerror = (errorMsg, url, lineNumber, columnNumber, errObj)->
    unless errObj?
      # Prevent error report to crash because a browser doesn't follow this convention
      # (or is that standard?)
      errObj =
        message: errorMsg
        context: _.toArray arguments
        stack: ''

    if errObj.hasBeenLogged then return
    errObj.hasBeenLogged = true

    console.error errObj

    # Avoid using utils that might not have been defined yet
    args = [].slice.call(arguments, 0)

    if args?[4]?
      name = args[4].name

      if name is 'InvalidStateError'
        # Already handled at feature_detection, no need to let it throw
        # and report to server
        return console.warn 'InvalidStateError: no worries, already handled'

      if name is 'ViewDestroyedError'
        # ViewDestroyedError are anoying but not critical: debugged from development
        # but not worth the noise in production logs
        return console.warn 'ViewDestroyedError: not reported'

    reportError errObj
