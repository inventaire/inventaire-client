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
  if err.selector?
    view.$el.trigger 'stopLoading'
    forms_.alert(view, err)
  else
    view.$el.trigger 'somethingWentWrong'
    _.error err, 'catchAlert err'

forms_.alert = (view, err)->
  {selector} = err
  errMessage = err.responseJSON?.status_verbose or err.message
  _.types [view, err, selector, errMessage], ['object', 'object', 'string', 'string']

  # avoid showing raw http error messages
  if /^\d/.test errMessage then errMessage = 'something went wrong :('

  _.log errMessage, "alert message on #{selector}"
  view.$el.trigger 'alert',
    message: _.i18n(errMessage)
    selector: selector

# format the error to be catched by forms_.catchAlert
# ex: forms_.throwError 'a title is required', '#titleField'
forms_.throwError = (message, selector, context...)->
  err = new Error message
  err.selector = selector
  err.context = context
  throw err
