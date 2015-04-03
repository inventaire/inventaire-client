username_ = require 'modules/user/lib/username_tests'
email_ = require 'modules/user/lib/email_tests'
password_ = require 'modules/user/lib/password_tests'
forms_ = require 'modules/general/lib/forms'
loadingPlugin = require 'modules/general/plugins/loading'

module.exports = ProfileSettings = Backbone.Marionette.ItemView.extend
  template: require './templates/profile_settings'
  className: 'profileSettings'
  behaviors:
    AlertBox: {}
    SuccessCheck: {}
    Loading: {}
    ConfirmationModal: {}
    TogglePassword: {}

  ui:
    username: '#usernameField'
    email: '#emailField'
    currentPassword: '#currentPassword'
    newPassword: '#newPassword'
    passwords: '.password'
    passwordUpdater: '#passwordUpdater'
    languagePicker: '#languagePicker'

  initialize: ->
    _.extend @, loadingPlugin
    @listenTo @model, 'change:picture', @render
    @listenTo app.vent, 'i18n:reset', ->
      @render()
      # can't be triggered the 'normal' way as the page is
      # re-rendered when the promise is fulfilled
      @ui.languagePicker.trigger 'check'

  onShow: -> app.execute 'foundation:reload'

  serializeData: ->
    attrs = @model.toJSON()
    return _.extend attrs,
      usernamePicker: @usernamePickerData()
      emailPicker: @emailPickerData()
      languages: @languagesData()
      changePicture:
        classes: 'max-large-profilePic'
      localCreationStrategy: attrs.creationStrategy is 'local'
      hasPassword: attrs.creationStrategy is 'local' or attrs.hasPassword

  usernamePickerData: -> pickerData @model, 'username'
  emailPickerData: -> pickerData @model, 'email'

  languagesData: ->
    languages = _.deepClone Lang
    currentLanguages = @model.get('language')
    languages[currentLanguages]?.selected = true
    return languages

  events:
    'click a#usernameButton': 'updateUsername'
    'click a#emailButton': 'updateEmail'
    'click a#updatePassword': 'updatePassword'
    'click #forgotPassword': -> app.execute 'show:forgot:password'
    'change select#languagePicker': 'changeLanguage'
    'click a#changePicture': 'changePicture'
    'click a#emailConfirmationRequest': 'emailConfirmationRequest'

  # USERNAME
  updateUsername: ->
    username = @ui.username.val()
    _.preq.start()
    .then @testUsername.bind(@, username)
    .then username_.verifyUsername.bind(null, username, '#usernameField')
    .then @sendUsernameRequest.bind(@, username)
    .catch forms_.catchAlert.bind(null, @)

  testUsername: (username)->
    testAttribute 'username', username, username_

  sendUsernameRequest: (username)->
    _.preq.post app.API.auth.usernameAvailability, {username: username}
    .then _.property('username')
    .then @confirmUsernameChange.bind(@)

  confirmUsernameChange: (username)->
    action = @updateUserUsername.bind @, username
    @askConfirmation action,
      requestedUsername: username
      currentUsername: app.user.get 'username'
      model: @model

  askConfirmation: (action, args)->
    @$el.trigger 'askConfirmation',
      confirmationText: _.i18n('username_change_confirmation', args)
      warningText: _.i18n('username_change_warning')
      action: action
      selector: '#usernameGroup'

  updateUserUsername: (username)->
    app.request 'user:update',
      attribute: 'username'
      value: username
      selector: '#usernameButton'

  # EMAIL

  updateEmail: ->
    email = @ui.email.val()
    _.preq.start()
    .then @testEmail.bind(@, email)
    .then @startLoading.bind(@, '#emailButton')
    .then email_.verifyAvailability.bind(null, email, "#emailField")
    .then email_.verifyExistance.bind(email_, email, '#emailField')
    .then @sendEmailRequest.bind(@, email)
    .then @showConfirmationEmailSuccessMessage.bind(@)
    .catch forms_.catchAlert.bind(null, @)
    .finally @hardStopLoading.bind(@)

  testEmail: (email)->
    testAttribute 'email', email, email_

  sendEmailRequest: (email)->
    _.preq.post app.API.auth.emailAvailability, {email: email}
    .then _.property('email')
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

    _.preq.start()
    .then -> password_.pass currentPassword, '#currentPasswordAlert'
    .then -> password_.pass newPassword, '#newPasswordAlert'
    .then @startLoading.bind(@, '#updatePassword')
    .then @confirmCurrentPassword.bind(@, currentPassword)
    .then @updateUserPassword.bind(@, currentPassword, newPassword)
    .then @passwordSuccessCheck.bind(@)
    .catch forms_.catchAlert.bind(null, @)
    .finally @stopLoading.bind(@)

  confirmCurrentPassword: (currentPassword)->
    app.request 'password:confirmation', currentPassword
    .catch (err)->
      if err.status is 401
        err = new Error('wrong password')
        err.selector = '#currentPasswordAlert'
        throw err
      else throw err

  updateUserPassword: (currentPassword, newPassword)->
    app.request 'password:update', currentPassword, newPassword

  passwordSuccessCheck: (password)->
    @ui.passwords.val('')
    @ui.passwordUpdater.trigger('check')

  passwordFail: (password)->
    @ui.passwordUpdater.trigger('fail')

  # LANGUAGE
  changeLanguage: (e)->
    lang = e.target.value
    if lang isnt app.user.get 'language'
      app.request 'user:update',
        attribute:'language'
        value: e.target.value
        selector: '#languagePicker'

  # PICTURE
  changePicture: require 'modules/user/lib/change_picture'


testAttribute = (attribute, value, validator_)->
  selector = "##{attribute}Field"
  if value is app.user.get attribute
    err = new Error("that's already your #{attribute}")
    err.selector = selector
    throw err
  else
    validator_.pass value, selector
    return value

pickerData = (model, attribute)->
  nameBase: attribute
  special: true
  field:
    value: model.get attribute
  button:
    text: _.i18n "change #{attribute}"
    classes: 'grey postfix'