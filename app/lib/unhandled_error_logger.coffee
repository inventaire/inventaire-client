{ reportError } = require 'lib/reports'

module.exports = ->
  # override window.onerror to always log the stacktrace
  window.onerror = (errorMsg, url, lineNumber, columnNumber, errObj)->
    if errObj.hasBeenLogged then return
    errObj.hasBeenLogged = true

    # avoid using utils that weren't defined yet
    args = [].slice.call(arguments, 0)

    if args?[4]?
      name = args[4].name

      if name is 'InvalidStateError'
        # already handled at feature_detection, no need to let it throw
        # and report to server
        return console.warn 'InvalidStateError: no worries, already handled'

      if name is 'ViewDestroyedError'
        # ViewDestroyedError are anoying but not critical: debugged from development
        # but not worth the noise in production logs
        return console.warn 'ViewDestroyedError: not reported'

    # excluding Chrome that do log the stacktrace by default
    if window.navigator.webkitGetGamepads?
      console.error errObj, onerrorSignature
    else
      err = parseErrorObject.apply null, args
      err.hasBeenLogged = true
      console.error.apply console, err, onerrorSignature

    reportError errObj

onerrorSignature = '(handled by window.onerror)'

parseErrorObject = (errorMsg, url, lineNumber, columnNumber, errObj)->
  # other arguments aren't necessary as already provided by Firefox
  # console.log {stack: errObj.stack}
  if errObj
    { stack, context } = errObj
    # prerender error object doesnt seem to have a stack, thus the stack?
    stack = stack?.split('\n')
    report = ["#{errorMsg} #{url} #{lineNumber}:#{columnNumber}", stack]
    if context? then report.push context
    return report
  else
    return [ errorMsg, url, lineNumber, columnNumber ]
