email_ = require 'modules/user/lib/email_tests'
forms_ = require 'modules/general/lib/forms'

module.exports = Backbone.Marionette.ItemView.extend
  template: require './templates/forgot_password'
  className: 'book-bg'
  behaviors:
    AlertBox: {}
    SuccessCheck: {}
    Loading: {}

  ui:
    email: '#emailField'
    confirmationEmailSent: '#confirmationEmailSent'

  serializeData: ->
    emailPicker: @emailPickerData()

  emailPickerData: ->
    nameBase: 'email'
    special: true
    field:
      value: app.user.get('email')
    button:
      text: _.i18n 'send email'
      classes: 'grey postfix'

  events: ->
    'click a#emailButton': 'lazySendEmail'

  initialize: ->
    @lazySendEmail = _.debounce @sendEmail.bind(@), 1500, true

  sendEmail: ->
    email = @ui.email.val()
    _.preq.start()
    .then -> email_.pass email, '#emailField'
    .then @startEmailLoading.bind(@)
    .then verifyKnownEmail.bind(null, email)
    .then @sendResetPasswordLink.bind(@, email)
    .then @showSuccessMessage.bind(@)
    .catch forms_.catchAlert.bind(null, @)
    .finally @stopLoading.bind(@)

  startEmailLoading: -> @$el.trigger 'loading', {selector: '#emailButton'}
  stopLoading: -> @$el.trigger 'stopLoading', {selector: '#emailButton'}

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