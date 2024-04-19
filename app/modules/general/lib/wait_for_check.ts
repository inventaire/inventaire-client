export default function (options) {
  let { selector, $selector, action, promise } = options
  // $selector or selector MUST be provided
  // if selector? then $selector = $(selector)
  if (!$selector) $selector = $(selector)
  $selector.trigger('loading', { selector })

  // action or promise MUST be provided
  if (action != null) promise = action()

  // success and/or error handlers MAY be provided
  promise
  .then(() => $selector.trigger('check'))
  .catch(err => $selector.trigger('fail', err))

  return promise
}
