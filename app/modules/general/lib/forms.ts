import { uniqueId } from 'underscore'
import { assertViewHasBehavior } from '#general/plugins/behaviors'
import assert_ from '#lib/assert_types'
import log_ from '#lib/loggers'
import { I18n, i18n } from '#user/lib/i18n'

export function pass (options) {
  const { value, tests, selector } = options
  for (const err in tests) {
    const test = tests[err]
    if (test(value)) throwError(err, selector, value)
  }
}

// verifies field value before the form is submitted
export async function earlyVerify (view, e, verificator) {
  // dont show early alert for empty fields as it feels a bit agressive
  if ($(e.target)?.val() !== '') {
    try {
      await verificator()
    } catch (err) {
      catchAlert(view, err)
    }
  }
}

// REQUIRES
// behaviors:
//   AlertBox: {}
// CONTRACT:
// if the error as a selector, it is an alert
// otherwise it's an operational error
// ex:
// (in a View context)
// doThingsThatThrowsErrorsWithSelector
// .catch catchAlert.bind(null, @)
// The selector can be any element, the alert-box will be appended to its parent
export function catchAlert (view, err) {
  // Avoid to display an alert on a simple duplicated request
  if (err.statusCode === 429) return log_.warn(err, 'duplicated request')
  assertViewHasBehavior(view, 'AlertBox')
  const { selector } = err
  view.$el.trigger('stopLoading', { selector })
  alert(view, err)
  log_.error(err, 'err passed to catchAlert')

  // Prevent the view to be re-rendered as that would hide the alert
  const alertId = uniqueId()
  view._preventRerender = true
  view._lastAlertId = alertId
  return setTimeout(removePreventRerenderFlag(view, alertId), 2000)
}

export const removePreventRerenderFlag = (view, alertId) => function () {
  if (view._lastAlertId !== alertId) return
  view._preventRerender = false
}

export function alert (view, err) {
  let message
  const { selector, i18n: translateErrMessage } = err
  let errMessage = err.richMessage || err.responseJSON?.status_verbose || err.message
  assert_.types([ view, err, selector, errMessage ], [ 'object', 'object', 'string|undefined', 'string' ])

  // Avoid showing raw http error messages
  if ((err.richMessage == null) && /^\d/.test(errMessage)) errMessage = 'something went wrong :('

  let logLabel = 'alert message'
  if (selector != null) logLabel += ` on ${selector}`
  log_.info({ errMessage, view }, logLabel)

  // Allow to pass a false flag to prevent the use of i18n
  // thus preventing to get it added to the list of strings to translate
  // The normal behavior should be to let operational errors be added
  // to the list to translate and remove them manually, rather than trying
  // to make i18n=false the default and cherry pick which should be translated
  // (which, for having tryied, is a pain)
  if (translateErrMessage === false) {
    message = errMessage
  } else {
    message = i18n(errMessage)
  }

  view.$el.trigger('alert', { message, selector })
}

export function bundleAlert (view, message, selector) {
  const err = new Error(message)
  err.selector = selector
  alert(view, err)
}

// format the error to be catched by catchAlert
// ex: throwError 'a title is required', '#titleField'
export function throwError (message, selector, ...context) {
  const err = new Error(I18n(message))
  err.selector = selector
  err.context = context
  // Form errors are user's errors, thus they don't need to be reported to the server
  // Non-standard convention: 499 = client user error
  err.statusCode = 499
  throw err
}
