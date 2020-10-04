import { reportError } from 'lib/reports'

export default () => {
  // Override window.onerror to always log the stacktrace
  window.onerror = function (errorMsg, url, lineNumber, columnNumber, errObj) {
    if (errObj == null) {
    // Prevent error report to crash because a browser doesn't follow this convention
    // (or is that standard?)
      errObj = {
        message: errorMsg,
        context: Array.from(arguments),
        stack: ''
      }
    }

    if (errObj.hasBeenLogged) return
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
        console.warn('InvalidStateError: no worries, already handled')
      } else if (name === 'ViewDestroyedError') {
        // ViewDestroyedError are anoying but not critical: debugged from development
        // but not worth the noise in production logs
        console.warn('ViewDestroyedError: not reported')
      }
    }

    reportError(errObj)
  }
}
