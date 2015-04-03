password_ = require 'modules/user/lib/password_tests'
forms_ = require 'modules/general/lib/forms'
behaviorsPlugin = require 'modules/general/plugins/behaviors'

module.exports = Backbone.Marionette.ItemView.extend
  behaviors:
    AlertBox: {}
    SuccessCheck: {}
    Loading: {}
    TogglePassword: {}

  template: require './templates/reset_password'
  className: 'book-bg'

  serializeData: ->
    passwordLabel: 'new password'
    username: app.user.get('username')

  ui:
    password: '#password'

  initialize: -> _.extend @, behaviorsPlugin

  events:
    'click #updatePassword': 'updatePassword'
    'click #forgotPassword': -> app.execute 'show:forgot:password'


  updatePassword: ->
    password = @ui.password.val()

    _.preq.start()
    .then -> password_.pass password, '#finalAlertbox'
    .then @startLoading.bind(@, '#updatePassword')
    .then @updateUserPassword.bind(@, password)
    .then @passwordSuccessCheck.bind(@)
    .catch forms_.catchAlert.bind(null, @)
    .finally @stopLoading.bind(@)

  updateUserPassword: (password)->
    app.execute 'prepare:login:redirect', 'home'
    # setting currentPassword to null make it be an empty string on server
    # thus the preference for undefined
    app.request 'password:update', undefined, password, '#password'
    .catch formatErr

  passwordSuccessCheck: ->
    @ui.passwords.val('')
    @ui.password.trigger('check')

formatErr = (err)->
  _.error err, 'formatErr'
  err.selector = '#finalAlertbox'
  throw err