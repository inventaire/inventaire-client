ValidEmailConfirmation = require 'modules/user/views/valid_email_confirmation'

module.exports = ->
  validEmail = app.request 'route:querystring', 'validEmail'
  if validEmail?
    # parsing boolean string
    validEmail = validEmail is 'true'
    setTimeout showValidEmailConfirmation.bind(null, validEmail), 2000

showValidEmailConfirmation = (validEmail)->
  # user.attribute.validEmail > querystring validEmail parameter
  # (even if hopefully, there is no reason for those to be different)
  if app.user.loggedIn then validEmail = app.user.get('validEmail')
  app.layout.modal.show new ValidEmailConfirmation {validEmail: validEmail}