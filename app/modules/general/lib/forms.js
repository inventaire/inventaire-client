/* eslint-disable
    import/no-duplicates,
    no-proto,
    no-return-assign,
    no-undef,
    no-var,
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
import error_ from 'lib/error'
let forms_
export default forms_ = {}

forms_.pass = function (options) {
  const { value, tests, selector } = options
  _.types([ value, tests, selector ], [ 'string', 'object', 'string' ])
  return (() => {
    const result = []
    for (const err in tests) {
      const test = tests[err]
      if (test(value)) {
        result.push(forms_.throwError(err, selector, value))
      } else {
        result.push(undefined)
      }
    }
    return result
  })()
}

// verifies field value before the form is submitted
forms_.earlyVerify = function (view, e, verificator) {
  // dont show early alert for empty fields as it feels a bit agressive
  if ($(e.target)?.val() !== '') {
    return Promise.try(verificator)
    .catch(forms_.catchAlert.bind(null, view))
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
// Promise.try doThingsThatThrowsErrorsWithSelector
// .catch forms_.catchAlert.bind(null, @)
// The selector can be any element, the alert-box will be appended to its parent
forms_.catchAlert = function (view, err) {
  // Avoid to display an alert on a simple duplicated request
  if (err.statusCode === 429) { return _.warn(err, 'duplicated request') }
  assertViewHasBehavior(view, 'AlertBox')
  const { selector } = err
  view.$el.trigger('stopLoading', { selector })
  forms_.alert(view, err)
  _.error(err, 'err passed to catchAlert')

  // Prevent the view to be re-rendered as that would hide the alert
  const alertId = _.uniqueId()
  view._preventRerender = true
  view._lastAlertId = alertId
  return setTimeout(removePreventRerenderFlag(view, alertId), 2000)
}

var removePreventRerenderFlag = (view, alertId) => function () {
  if (view._lastAlertId !== alertId) { return }
  return view._preventRerender = false
}

forms_.alert = function (view, err) {
  let message
  const { selector, i18n } = err
  let errMessage = err.richMessage || err.responseJSON?.status_verbose || err.message
  _.types([ view, err, selector, errMessage ], [ 'object', 'object', 'string|undefined', 'string' ])

  // Avoid showing raw http error messages
  if ((err.richMessage == null) && /^\d/.test(errMessage)) { errMessage = 'something went wrong :(' }

  let logLabel = 'alert message'
  if (selector != null) { logLabel += ` on ${selector}` }
  _.log({ errMessage, view }, logLabel)

  // Allow to pass a false flag to prevent the use of _.i18n
  // thus preventing to get it added to the list of strings to translate
  // The normal behavior should be to let operational errors be added
  // to the list to translate and remove them manually, rather than trying
  // to make i18n=false the default and cherry pick which should be translated
  // (which, for having tryied, is a pain)
  if (i18n === false) {
    message = errMessage
  } else { message = _.i18n(errMessage) }

  return view.$el.trigger('alert', { message, selector })
}

forms_.bundleAlert = function (view, message, selector) {
  const err = new Error(message)
  err.selector = selector
  return forms_.alert(view, err)
}

// format the error to be catched by forms_.catchAlert
// ex: forms_.throwError 'a title is required', '#titleField'
forms_.throwError = function (message, selector, ...context) {
  const err = new Error(message)
  err.selector = selector
  err.context = context
  // Form errors are user's errors, thus they don't need to be reported to the server
  // Non-standard convention: 499 = client user error
  err.statusCode = 499
  throw err
}

var assertViewHasBehavior = function (view, name) {
  for (const behavior of view._behaviors) {
    if (behavior.__proto__.name === name) { return }
  }
  throw error_.new(`view misses behavior: ${name}`, 500)
}
