email_ = require 'modules/user/lib/email_tests'
password_ = require 'modules/user/lib/password_tests'
forms_ = require 'modules/general/lib/forms'
error_ = require 'lib/error'
behaviorsPlugin = require 'modules/general/plugins/behaviors'
{ languages: activeLanguages } = require 'lib/active_languages'
{ testAttribute, pickerData } = require '../lib/helpers'

module.exports = Marionette.ItemView.extend
  template: require './templates/account_settings'
  className: 'accountSettings'
  behaviors:
    AlertBox: {}
    SuccessCheck: {}
    Loading: {}
    TogglePassword: {}

  ui:
    email: '#emailField'
    currentPassword: '#currentPassword'
    newPassword: '#newPassword'
    passwords: '.password'
    passwordUpdater: '#passwordUpdater'
    languagePicker: '#languagePicker'

  initialize: ->
    _.extend @, behaviorsPlugin

  serializeData: ->
    attrs = @model.toJSON()
    return _.extend attrs,
      emailPicker: @emailPickerData()
      languages: _.log @languagesData(), 'languagesData'

  emailPickerData: -> pickerData @model, 'email'

  languagesData: ->
    languages = _.deepClone activeLanguages
    currentLanguage = _.shortLang @model.get('language')
    languages[currentLanguage]?.selected = true
    return languages

  events:
    'click a#emailButton': 'updateEmail'
    'click a#emailConfirmationRequest': 'emailConfirmationRequest'
    'change select#languagePicker': 'changeLanguage'
    'click a#updatePassword': 'updatePassword'
    'click #forgotPassword': -> app.execute 'show:forgot:password'
    'click #deleteAccount': 'askDeleteAccountConfirmation'

  # EMAIL

  updateEmail: ->
    email = @ui.email.val()
    Promise.try @testEmail.bind(@, email)
    .then @startLoading.bind(@, '#emailButton')
    .then email_.verifyAvailability.bind(null, email, '#emailField')
    .then @sendEmailRequest.bind(@, email)
    .then @showConfirmationEmailSuccessMessage.bind(@)
    .catch forms_.catchAlert.bind(null, @)
    .finally @hardStopLoading.bind(@)

  testEmail: (email)->
    testAttribute 'email', email, email_

  sendEmailRequest: (email)->
    _.preq.get app.API.auth.emailAvailability(email)
    .get 'email'
    .then @sendEmailChangeRequest

  sendEmailChangeRequest: (email)->
    app.request 'user:update',
      attribute: 'email'
      value: email
      selector: '#emailField'

  hardStopLoading: ->
    # triggering stopLoading wasnt working
    # temporary solution
    @$el.find('.loading').empty()

  # EMAIL CONFIRMATION
  emailConfirmationRequest: ->
    $('#notValidEmail').fadeOut()
    app.request 'email:confirmation:request'
    .then @showConfirmationEmailSuccessMessage

  showConfirmationEmailSuccessMessage: ->
    $('#confirmationEmailSent').fadeIn()
    $('#emailButton').once 'click', @hideConfirmationEmailSent

  hideConfirmationEmailSent: ->
    $('#confirmationEmailSent').fadeOut()

  # PASSWORD

  updatePassword: ->
    currentPassword = @ui.currentPassword.val()
    newPassword = @ui.newPassword.val()

    Promise.try -> password_.pass currentPassword, '#currentPasswordAlert'
    .then -> password_.pass newPassword, '#newPasswordAlert'
    .then @startLoading.bind(@, '#updatePassword')
    .then @confirmCurrentPassword.bind(@, currentPassword)
    .then @updateUserPassword.bind(@, currentPassword, newPassword)
    .then @ifViewIsIntact('passwordSuccessCheck')
    .catch @ifViewIsIntact('passwordFail')
    .catch forms_.catchAlert.bind(null, @)
    .finally @stopLoading.bind(@)

  confirmCurrentPassword: (currentPassword)->
    app.request 'password:confirmation', currentPassword
    .catch (err)->
      if err.statusCode is 401
        err = error_.new 'wrong password', 400
        err.selector = '#currentPasswordAlert'
        throw err
      else throw err

  updateUserPassword: (currentPassword, newPassword)->
    app.request 'password:update', currentPassword, newPassword

  passwordSuccessCheck: ->
    @ui.passwords.val('')
    @ui.passwordUpdater.trigger('check')

  passwordFail: (err)->
    @ui.passwordUpdater.trigger('fail')
    throw err

  # LANGUAGE
  changeLanguage: (e)->
    app.request 'user:update',
      attribute:'language'
      value: e.target.value
      selector: '#languagePicker'

  # DELETE ACCOUNT
  askDeleteAccountConfirmation: ->
    args = { username: @model.get('username') }
    app.execute 'ask:confirmation',
      confirmationText: _.i18n('delete_account_confirmation', args)
      warningText: _.i18n 'cant_undo_warning'
      action: @model.deleteAccount.bind(@model)
      selector: '#usernameGroup'
      formAction: sendDeletionFeedback
      formLabel: "that would really help us if you could say a few words about why you're leaving:"
      formPlaceholder: "our love wasn't possible because"
      yes: 'delete your account'
      no: 'cancel'

sendDeletionFeedback = (message)->
  _.preq.post app.API.feedback,
    subject: '[account deletion]'
    message: message
