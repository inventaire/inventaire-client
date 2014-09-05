module.exports.initialize = ->

  # excluding Chrome
  unless window.navigator.webkitGetGamepads?
    window.onerror = (errorMsg, url, lineNumber, columnNumber, errObj)->
      # other arguments aren't necessary as already provided by Firefox
      # console.log {stack: errObj.stack}
      console.error errObj.stack.split('\n')