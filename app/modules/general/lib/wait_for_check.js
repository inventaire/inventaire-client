export default function (options) {
  let { selector, $selector, action, promise, success, error } = options
  // $selector or selector MUST be provided
  // if selector? then $selector = $(selector)
  if (!$selector) { $selector = $(selector) }
  $selector.trigger('loading', { selector })

  // action or promise MUST be provided
  if (action != null) { promise = action() }

  // success and/or error handlers MAY be provided
  promise
  .then(res => $selector.trigger('check', success))
  // eslint-disable-next-line handle-callback-err
  .catch(err => $selector.trigger('fail', error))

  return promise
};
