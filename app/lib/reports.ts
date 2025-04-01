import { detectedEnv } from './env_config'

// Duplicated from './metadata/update' to keep the maximum priority in import order
const isPrerenderSession = (window.navigator?.userAgent.match('Prerender') != null)

export async function reportError (err) {
  // Do not try to report errors in tests

  if (detectedEnv == null) return

  if (err.hasBeenReported) return
  err.hasBeenReported = true
  // errors that are assigned a 4xx error code are user errors
  // that don't need to be reported to the server
  // Ex: invalid form input
  if ((err.statusCode != null) && (err.statusCode < 500)) return

  const data = {
    error: {
      // not simply passing the err object as its properties wouldn't be sent
      message: err.message,
      stack: err.stack,
      context: err.context,
      statusCode: err.statusCode,
    },
  }

  try {
    // (1)
    await fetch('/api/reports?action=error-report', {
      method: 'post',
      headers: { 'content-type': 'application/json' },
      body: stringifyData(data),
    })
  } catch (err) {
    console.error('could not report error', err)
    // Do not rethrow error to prevent an error reporting loop
  }
}

const sendOnlineReport = function () {
  // Don't send online report if the page isn't the active tab
  if (document.visibilityState !== 'hidden') {
    // (1)
    // No need to send a body
    return fetch('/api/reports?action=online', { method: 'post' })
  }
}

if (!isPrerenderSession) {
  // Send a POST requests every 30 secondes to notify the server that we are online,
  // useful for maintainance operations.
  setInterval(sendOnlineReport, 30 * 1000)
}

// (1): Using fetch directly instead of preq to be able to report errors
// happening before preq is initialized

const stringifyData = function (data) {
  try {
    return JSON.stringify(data)
  } catch (err) {
    // Typically a 'cyclic object value' error
    data.context = `context couldn't be attached: ${err.message}`
    return JSON.stringify(data)
  }
}
