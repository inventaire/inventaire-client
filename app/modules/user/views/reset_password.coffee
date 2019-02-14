password_ = require 'modules/user/lib/password_tests'
forms_ = require 'modules/general/lib/forms'
behaviorsPlugin = require 'modules/general/plugins/behaviors'

module.exports = Marionette.ItemView.extend
  className: 'authMenu login'
  template: require './templates/reset_password'
  behaviors:
    AlertBox: {}
    SuccessCheck: {}
    Loading: {}
    TogglePassword: {}

  ui:
    password: '#password'

  initialize: -> _.extend @, behaviorsPlugin

  events:
    'click #updatePassword': 'updatePassword'
    'click #forgotPassword': -> app.execute 'show:forgot:password'

  serializeData: ->
    passwordLabel: 'new password'
    username: app.user.get('username')

  updatePassword: ->
    password = @ui.password.val()

    Promise.try -> password_.pass password, '#finalAlertbox'
    .then @startLoading.bind(@, '#updatePassword')
    .then @ifViewIsIntact('updateUserPassword', password)
    .then @ifViewIsIntact('passwordSuccessCheck')
    .catch forms_.catchAlert.bind(null, @)
    .finally @stopLoading.bind(@)

  updateUserPassword: (password)->
    app.execute 'prepare:login:redirect', 'home'
    # Setting currentPassword to null makes it be an empty string on server
    # thus the preference for undefined
    app.request 'password:update', undefined, password, '#password'
    .catch formatErr

  passwordSuccessCheck: ->
    @ui.password.val('')
    @ui.password.trigger('check')

formatErr = (err)->
  _.error err, 'formatErr'
  err.selector = '#finalAlertbox'
  throw err
