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
      $.post '/api/logs/public', {error: report, context: navigator.userAgent}
