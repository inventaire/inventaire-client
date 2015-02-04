window.reportErr = (obj)->
  obj or= {}

  context = []
  if app?.user?.loggedIn
    context = ["user: #{app.user.id} (#{app.user.get('username')})"]
  else
    context = ["user: not logged user"]
  context.push navigator.userAgent
  obj.context = context

  $.post '/api/logs/public', obj


module.exports.initialize = ->
  # excluding Chrome
  unless window.navigator.webkitGetGamepads?
    window.onerror = (errorMsg, url, lineNumber, columnNumber, errObj)->
      # other arguments aren't necessary as already provided by Firefox
      # console.log {stack: errObj.stack}
      if errObj
        stack = errObj.stack.split('\n')
        report = ["#{errorMsg} #{url} #{lineNumber}:#{columnNumber}", stack]
      else
        report = [ errorMsg, url, lineNumber, columnNumber ]

      console.error.apply console, report
      window.reportErr(report)
