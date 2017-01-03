formatError = (message, context)->
  err = new Error message

  # converting arguments object to array for readability in logs
  if _.isArguments context then context = _.toArray context
  err.context = context
  err.timestamp = new Date().toISOString()

  return err

module.exports = error_ =
  new: formatError
  # newWithSelector: use forms_.throwError instead

  complete: (selector, err)->
    err.selector = selector
    return err

  # /!\ throws the error while error_.complete only returns it.
  # This difference is justified by the different use of both functions
  Complete: (selector, i18n)-> (err)->
    err.selector = selector
    # Only the false flag has an effect
    if i18n is false then err.i18n = i18n
    throw err

  reject: (message, context)->
    err = formatError message, context
    return Promise.reject err
