module.exports = (options)->
  {selector, $selector, action, promise, success, error} = options
  # $selector or selector MUST be provided
  # if selector? then $selector = $(selector)
  $selector or= $(selector)
  $selector.trigger 'loading', {selector: selector}

  # action or promise MUST be provided
  if action? then promise = action()

  # success and/or error handlers CAN be provided
  promise
  .then (res)->
    $selector.trigger('check', success)
  .catch (err)->
    _.error err, 'waitForCheck err'
    $selector.trigger('fail', error)

  return promise
