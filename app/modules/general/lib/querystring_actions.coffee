ValidEmailConfirmation = require 'modules/user/views/valid_email_confirmation'

module.exports = ->
  validEmail = app.request 'route:querystring', 'validEmail'
  if validEmail?
    setTimeout showValidEmailConfirmation.bind(null, validEmail), 2000

showValidEmailConfirmation = (validEmail)->
  app.layout.modal.show new ValidEmailConfirmation {validEmail: validEmail}