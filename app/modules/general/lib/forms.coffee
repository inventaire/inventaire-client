module.exports = forms_ = {}

forms_.pass = (options)->
  { value, tests, selector } = options
  _.types [value, tests, selector], ['string', 'object', 'string']
  for err, test of tests
    if test value
      forms_.throwError err, selector, value

# verifies field value before the form is submitted
forms_.earlyVerify = (view, e, verificator)->
  # dont show early alert for empty fields as it feels a bit agressive
  unless $(e.target)?.val() is ''
    _.preq.start
    .then verificator
    .catch forms_.catchAlert.bind(null, view)

# REQUIRES
# behaviors:
#   AlertBox: {}
# CONTRACT:
# if the error as a selector, it is an alert
# otherwise it's an operational error
# ex:
# (in a View context)
# _.preq.start
# .then doThingsThatThrowsErrorsWithSelector
# .catch forms_.catchAlert.bind(null, @)
# The selector can be any element, the alert-box will be appended to its parent
forms_.catchAlert = (view, err)->
  # Avoid to display an alert on a simple dupplicated request
  if err.status is 429 then return _.warn err, 'dupplicated request'
  if err.selector?
    view.$el.trigger 'stopLoading'
    forms_.alert(view, err)
    _.error err, 'err passed to catchAlert'
  else
    view.$el.trigger 'somethingWentWrong'
    _.error err, 'error catched by forms_.catchAlert but the error object miss a selector'

forms_.alert = (view, err)->
  { selector, i18n } = err
  errMessage = err.responseJSON?.status_verbose or err.message
  _.types [view, err, selector, errMessage], ['object', 'object', 'string', 'string']

  # Avoid showing raw http error messages
  if /^\d/.test errMessage then errMessage = 'something went wrong :('

  _.log errMessage, "alert message on #{selector}"

  # Allow to pass a false flag to prevent the use of _.i18n
  # thus preventing to get it added to the list of strings to translate
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
  throw err
