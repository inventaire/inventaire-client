formatError = (message, status, context)->
  # Accept a status number as second argument as done on the server
  # cf server/lib/error/format_error.coffee
  # Allows for instance to not report non-operational/user errors to the server
  # in case status is a 4xx error
  unless _.isNumber status then [ status, context ] = [ null, status ]

  err = new Error message
  # Set status to a 4xx error for user errors to prevent it
  # to be unnecessary reported to the server:
  # We don't need to open an issue everytime miss type their password
  err.status = status

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
