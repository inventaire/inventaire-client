ValidEmailConfirmation = require 'modules/user/views/valid_email_confirmation'

module.exports = ->
  validEmail = app.request 'route:querystring:get', 'validEmail'
  if validEmail?
    # parsing boolean string
    validEmail = validEmail is 'true'

    app.request 'waitForLayout'
    .then showValidEmailConfirmation.bind(null, validEmail)

showValidEmailConfirmation = (validEmail)->
  # user.attribute.validEmail has priority over the validEmail querystring
  # (even if hopefully, there is no reason for those to be different)
  if app.user.loggedIn then validEmail = app.user.get 'validEmail'
  app.layout.modal.show new ValidEmailConfirmation {validEmail: validEmail}