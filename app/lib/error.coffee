module.exports = error_ =
  new: (message, context)->
    err = new Error message
    err.context = context
    return err

  newWithSelector: (message, selector, context)->
    err = new Error message
    err.selector = selector
    err.context = context
    return err

  Complete: (selector)->
    return fn = (err)->
      err.selector = selector
      throw err
