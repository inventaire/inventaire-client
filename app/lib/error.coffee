module.exports = error_ =
  new: (message, context)->
    err = new Error message
    err.context = context
    throw err
