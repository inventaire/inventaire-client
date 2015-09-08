module.exports = error_ =
  new: (message, context)->
    err = new Error message
    err.context = context
    throw err

  newWithSelector: (message, selector, context)->
    err = new Error message
    err.selector = selector
    err.context = context
    throw err