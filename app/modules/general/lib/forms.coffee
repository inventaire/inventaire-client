error_ = require 'lib/error'

module.exports = forms_ = {}

forms_.pass = (options)->
  { value, tests, selector } = options
  _.types [ value, tests, selector ], [ 'string', 'object', 'string' ]
  for err, test of tests
    if test value
      forms_.throwError err, selector, value

# verifies field value before the form is submitted
forms_.earlyVerify = (view, e, verificator)->
  # dont show early alert for empty fields as it feels a bit agressive
  unless $(e.target)?.val() is ''
    Promise.try verificator
    .catch forms_.catchAlert.bind(null, view)

# REQUIRES
# behaviors:
#   AlertBox: {}
# CONTRACT:
# if the error as a selector, it is an alert
# otherwise it's an operational error
# ex:
# (in a View context)
# Promise.try doThingsThatThrowsErrorsWithSelector
# .catch forms_.catchAlert.bind(null, @)
# The selector can be any element, the alert-box will be appended to its parent
forms_.catchAlert = (view, err)->
  # Avoid to display an alert on a simple duplicated request
  if err.statusCode is 429 then return _.warn err, 'duplicated request'
  assertViewHasBehavior view, 'AlertBox'
  view.$el.trigger 'stopLoading'
  forms_.alert view, err
  _.error err, 'err passed to catchAlert'

forms_.alert = (view, err)->
  { selector, i18n } = err
  errMessage = err.responseJSON?.status_verbose or err.message
  _.types [ view, err, selector, errMessage ], [ 'object', 'object', 'string|undefined', 'string' ]

  # Avoid showing raw http error messages
  if /^\d/.test errMessage then errMessage = 'something went wrong :('

  logLabel = 'alert message'
  if selector? then logLabel += "on #{selector}"
  _.log { errMessage, view }, logLabel

  # Allow to pass a false flag to prevent the use of _.i18n
  # thus preventing to get it added to the list of strings to translate
  # The normal behavior should be to let operational errors be added
  # to the list to translate and remove them manually, rather than trying
  # to make i18n=false the default and cherry pick which should be translated
  # (which, for having tryied, is a pain)
  if i18n is false then message = errMessage
  else message = _.i18n errMessage

  view.$el.trigger 'alert', { message, selector }

forms_.bundleAlert = (view, message, selector)->
  err = new Error message
  err.selector = selector
  forms_.alert view, err

# format the error to be catched by forms_.catchAlert
# ex: forms_.throwError 'a title is required', '#titleField'
forms_.throwError = (message, selector, context...)->
  err = new Error message
  err.selector = selector
  err.context = context
  # Form errors are user's errors, thus they don't need to be reported to the server
  # Non-standard convention: 499 = client user error
  err.statusCode = 499
  throw err

assertViewHasBehavior = (view, name)->
  for behavior in view._behaviors
    if behavior.__proto__.name is name then return
  throw error_.new "view misses behavior: #{name}", 500
