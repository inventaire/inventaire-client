ValidEmailConfirmation = require 'modules/user/views/valid_email_confirmation'

module.exports = ->
  validEmail = app.request 'querystring:get', 'validEmail'
  if validEmail?
    # we need to wait for app.user to be ready to get the validEmail value
    app.request 'wait:for', 'user'
    .then -> app.request 'wait:for', 'layout'
    .then showValidEmailConfirmation.bind(null, validEmail)

showValidEmailConfirmation = (validEmail)->
  # user.attribute.validEmail has priority over the validEmail querystring
  # (even if hopefully, there is no reason for those to be different)
  if app.user.loggedIn then validEmail = app.user.get 'validEmail'
  app.layout.modal.show new ValidEmailConfirmation { validEmail }
