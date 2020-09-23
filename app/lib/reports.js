export default {
  reportError (err) {
    if (err.hasBeenReported) { return }
    err.hasBeenReported = true
    // errors that are assigned a 4xx error code are user errors
    // that don't need to be reported to the server
    // Ex: invalid form input
    if ((err.statusCode != null) && (err.statusCode < 500)) { return }

    err.envContext = getEnvContext()

    const data = {
      error: {
        // not simply passing the err object as its properties wouldn't be sent
        message: err.message,
        stack: err.stack,
        context: err.context,
        statusCode: err.statusCode
      }
    }

    // (1)
    return $.post({
      url: '/api/reports?action=error-report',
      // jquery defaults to x-www-form-urlencoded
      headers: { 'content-type': 'application/json' },
      data: stringifyData(data)
    })
  }
}

var getEnvContext = function () {
  let userData
  let envContext = []
  if (app?.user?.loggedIn) {
    const {
      id
    } = app.user
    const username = app.user.get('username')
    if ((id != null) && (username != null)) {
      userData = `user: ${id} (${username})`
    } else {
      userData = 'user logged in but error happened before data arrived'
    }
  } else {
    userData = 'user: not logged user'
  }

  envContext = [
    userData,
    navigator.userAgent
  ]

  return envContext
}

const sendOnlineReport = function () {
  // Don't send online report if the page isn't the active tab
  if (document.visibilityState !== 'hidden') {
    // (1)
    // No need to send a body
    return $.post('/api/reports?action=online')
  }
}

// Send a POST requests every 30 secondes to notify the server that we are online,
// useful for maintainance operations.
setInterval(sendOnlineReport, 30 * 1000)

// (1): Using jQuery promise instead of preq to be able to report errors
// happening before preq is initialized

var stringifyData = function (data) {
  try {
    return JSON.stringify(data)
  } catch (err) {
    // Typically a 'cyclic object value' error
    data.context = `context couldn't be attached: ${err.message}`
    return JSON.stringify(data)
  }
}
