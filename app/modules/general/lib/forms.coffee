module.exports = forms_ = {}

forms_.pass = (options)->
  {value, tests, selector} = options
  _.types [value, tests, selector], ['string', 'object', 'string']
  for err, test of tests
    if test(value)
      err = new Error(err)
      err.selector = selector
      throw err

# verifies field value before the form is submitted
forms_.earlyVerify = (view, e, verificator)->
  # dont show early alert for empty fields as it feels a bit agressive
  unless $(e.target)?.val() is ''
    _.preq.start()
    .then verificator
    .catch forms_.catchAlert.bind(null, view)

# CONTRACT:
# if the error as a selector, it is an alert
# otherwise it's an operational error
# ex:
# (in a View context)
# _.preq.start()
# .then doThingsThatThrowsErrorsWithSelector
# .catch forms_.catchAlert.bind(null, @)
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

  _.log errMessage, "alert message on #{selector}"
  view.$el.trigger 'alert',
    message: _.i18n(errMessage)
    selector: selector
