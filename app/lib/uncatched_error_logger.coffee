module.exports.initialize = ->

  # excluding Chrome
  unless window.navigator.webkitGetGamepads?
    window.onerror = (errorMsg, url, lineNumber, columnNumber, errObj)->
      # other arguments aren't necessary as already provided by Firefox
      # console.log {stack: errObj.stack}
      if errObj then console.error errObj.stack.split('\n')
      else console.error errorMsg, url, lineNumber, columnNumber
