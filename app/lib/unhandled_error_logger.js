import { reportError } from 'lib/reports'

export default () => // override window.onerror to always log the stacktrace
  window.onerror = function (errorMsg, url, lineNumber, columnNumber, errObj) {
    if (errObj == null) {
    // Prevent error report to crash because a browser doesn't follow this convention
    // (or is that standard?)
      errObj = {
        message: errorMsg,
        context: _.toArray(arguments),
        stack: ''
      }
    }

    if (errObj.hasBeenLogged) { return }
    errObj.hasBeenLogged = true

    console.error(errObj, errObj.context)

    // Avoid using utils that might not have been defined yet
    const args = [].slice.call(arguments, 0)

    if (args?.[4] != null) {
      const {
        name
      } = args[4]

      if (name === 'InvalidStateError') {
      // Already handled at feature_detection, no need to let it throw
      // and report to server
        return console.warn('InvalidStateError: no worries, already handled')
      }

      if (name === 'ViewDestroyedError') {
      // ViewDestroyedError are anoying but not critical: debugged from development
      // but not worth the noise in production logs
        return console.warn('ViewDestroyedError: not reported')
      }
    }

    return reportError(errObj)
  }
