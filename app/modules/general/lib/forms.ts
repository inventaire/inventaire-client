import { newError } from '#app/lib/error'
import { I18n } from '#user/lib/i18n'

export function pass (options) {
  const { value, tests, selector } = options
  for (const err in tests) {
    const test = tests[err]
    if (test(value)) throwError(err, selector, value)
  }
}

// format the error to be catched by catchAlert
// ex: throwError 'a title is required', '#titleField'
export function throwError (message, selector, ...context) {
  const err = newError(I18n(message))
  err.selector = selector
  err.context = context
  // Form errors are user's errors, thus they don't need to be reported to the server
  // Non-standard convention: 499 = client user error
  err.statusCode = 499
  throw err
}
