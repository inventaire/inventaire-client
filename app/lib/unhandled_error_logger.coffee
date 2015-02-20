module.exports.initialize = ->

  # override window.onerror to always log the stacktrace
  window.onerror = ->

    # avoid using utils that weren't defined yet
    args = [].slice.call(arguments, 0)

    if JSON.stringify(args) is '["InvalidStateError","",0,0,null]'
      # already handled at feature_detection, no need to let it throw
      # and report to server
      return console.warn('InvalidStateError: no worries, already handled')


    err = parseErrorObject.apply null, args

    # excluding Chrome that do log the stacktrace by default
    unless window.navigator.webkitGetGamepads?
      console.error.apply console, err

    window.reportErr(err)



parseErrorObject = (errorMsg, url, lineNumber, columnNumber, errObj)->
  # other arguments aren't necessary as already provided by Firefox
  # console.log {stack: errObj.stack}
  if errObj
    stack = errObj.stack.split('\n')
    return ["#{errorMsg} #{url} #{lineNumber}:#{columnNumber}", stack]
  else
    return [ errorMsg, url, lineNumber, columnNumber ]


window.reportErr = (report)->
  unless report?.error?
    err = report
    report =
      error: err

  report.context = getContext()
  if app?.session?.recordError? then app.session.recordError report
  else $.post '/api/logs/public', report

getContext = ->
  context = []
  if app?.user?.loggedIn
    id = app.user.id
    username = app.user.get('username')
    if id? and username?
      userData = "user: #{id} (#{username})"
    else
      userData = "user logged in but error happened before data arrived"
  else
    userData = "user: not logged user"

  context = [
    userData
    navigator.userAgent
  ]

  return context