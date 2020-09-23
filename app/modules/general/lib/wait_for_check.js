/* eslint-disable
    handle-callback-err,
    no-undef,
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
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
  .catch(err => $selector.trigger('fail', error))

  return promise
};
