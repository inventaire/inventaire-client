formatError = (message, statusCode, context)->
  # Accept a statusCode number as second argument as done on the server
  # cf server/lib/error/format_error.coffee
  # Allows for instance to not report non-operational/user errors to the server
  # in case statusCode is a 4xx error

  # Default to client implementation errors: 599
  unless _.isNumber statusCode then [ statusCode, context ] = [ 599, statusCode ]

  err = new Error message
  # Set statusCode to a 4xx error for user errors to prevent it
  # to be unnecessary reported to the server:
  # We don't need to open an issue everytime miss type their password
  err.statusCode = statusCode

  # converting arguments object to array for readability in logs
  if _.isArguments context then context = _.toArray context
  err.context = context
  err.timestamp = new Date().toISOString()

  return err

module.exports = error_ =
  new: formatError
  # newWithSelector: use forms_.throwError instead

  complete: (err, selector, i18n)->
    err.i18n = i18n isnt false
    err.selector = selector
    return err

  # /!\ throws the error while error_.complete only returns it.
  # This difference is justified by the different use of both functions
  Complete: (selector, i18n)-> (err)->
    throw error_.complete err, selector, i18n

  reject: (message, context)->
    err = formatError message, context
    return Promise.reject err

  # Log and report formatted errors to the server, without throwing
  report: (message, context)->
    # Non-standard convention: 599 = client implementation error
    err = formatError message, 599, context
    _.error err, message
    return
