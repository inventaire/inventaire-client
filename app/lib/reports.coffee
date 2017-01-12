module.exports =
  reportError: (err)->
    if err.hasBeenReported then return
    err.hasBeenReported = true

    err.envContext = getEnvContext()
    $.post '/api/reports/public?action=error-report',
      error:
        # not simply passing the err object as its properties wouldn't be sent
        message: err.message
        stack: err.stack
        context: err.context

getEnvContext = ->
  envContext = []
  if app?.user?.loggedIn
    id = app.user.id
    username = app.user.get('username')
    if id? and username?
      userData = "user: #{id} (#{username})"
    else
      userData = "user logged in but error happened before data arrived"
  else
    userData = "user: not logged user"

  envContext = [
    userData
    navigator.userAgent
  ]

  return envContext

sendOnlineReport = ->
  # Don't send online report if the page isn't the active tab
  if document.visibilityState isnt 'hidden'
    # Using jQuery promise instead of preq to be able to report errors
    # happening before preq is initialized
    $.post '/api/reports/public?action=online', { online: true }

# Send a POST requests every 30 secondes to notify the server that we are online,
# useful for maintainance operations.
setInterval sendOnlineReport, 30*1000
