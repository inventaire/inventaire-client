email_ = require 'modules/user/lib/email_tests'
forms_ = require 'modules/general/lib/forms'
behaviorsPlugin = require 'modules/general/plugins/behaviors'

module.exports = Marionette.ItemView.extend
  className: 'authMenu login'
  template: require './templates/forgot_password'
  behaviors:
    AlertBox: {}
    SuccessCheck: {}
    Loading: {}

  ui:
    email: '#emailField'
    confirmationEmailSent: '#confirmationEmailSent'

  initialize: ->
    _.extend @, behaviorsPlugin
    @lazySendEmail = _.debounce @sendEmail.bind(@), 1500, true

  serializeData: ->
    emailPicker: @emailPickerData()
    header: @headerData()

  headerData: ->
    if @options.createPasswordMode then 'create a password'
    else 'forgot password?'

  emailPickerData: ->
    nameBase: 'email'
    special: true
    field:
      value: app.user.get('email')
      placeholder: _.i18n 'email address'
    button:
      text: _.i18n 'send email'
      classes: 'grey postfix'

  events: ->
    'click a#emailButton': 'lazySendEmail'

  sendEmail: ->
    email = @ui.email.val()
    _.preq.try -> email_.pass email, '#emailField'
    .then @startLoading.bind(@, '#emailButton')
    .then verifyKnownEmail.bind(null, email)
    .then @sendResetPasswordLink.bind(@, email)
    .then @showSuccessMessage.bind(@)
    .catch forms_.catchAlert.bind(null, @)
    .finally @stopLoading.bind(@)

  sendResetPasswordLink: (email)->
    app.request 'password:reset:request', email
    .catch formatErr

  showSuccessMessage: ->
    @ui.confirmationEmailSent.fadeIn()


verifyKnownEmail = (email)->
  # re-using verifyAvailability but with the opposite expectaction:
  # if it throws an error, the email is known and that's the desired result here
  # thus the error is catched
  email_.verifyAvailability(email, "#emailField")
  .then unknownEmail
  .catch (err)->
    if err.status is 400 then 'known email'
    else throw err

unknownEmail = ->
  formatErr new Error('this email is unknown')

formatErr = (err)->
  err.selector = '#emailField'
  throw err