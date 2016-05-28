formatError = (message, context)->
  err = new Error message

  # converting arguments object to array for readability in logs
  if _.isArguments context then context = _.toArray context
  err.context = context

  return err

error_ =
  new: formatError
  # newWithSelector: use forms_.throwError instead

  complete: (selector, err)->
    err.selector = selector
    return err

  reject: (message, context)->
    err = formatError message, context
    return Promise.reject err


# /!\ throws the error while error_.complete only returns it.
# this difference is justified by the different use of both functions:
error_.Complete = (selector)->
  return throwComplete.bind null, selector

throwComplete = (selector, err)->
  err.selector = selector
  throw err

module.exports = error_
