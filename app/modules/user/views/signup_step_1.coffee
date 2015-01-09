usernameTests = require 'modules/user/lib/username_tests'

module.exports = class SignupStep1 extends Backbone.Marionette.ItemView
  className: 'book-bg'
  template: require './templates/signup_step1'
  behaviors:
    AlertBox: {}
    SuccessCheck: {}

  ui:
    username: '#usernameField'

  serializeData: ->
    attrs =
      usernamePicker:
        nameBase: 'username'
        special: true
        field:
          value: @model.get('username')
        button:
          text: _.i18n 'validate'
    return _.extend attrs, @model.toJSON()


  onShow: ->
    app.execute 'foundation:reload'

  events:
    'click #usernameButton': 'verifyUsername'

  verifyUsername: ->
    usernameTests.validate
      username: $('#usernameField').val()
      success: @sendUsernameRequest.bind(@)
      view: @

  sendUsernameRequest: (requestedUsername)->
    $.post(app.API.auth.username, {username: requestedUsername})
    .then (res)=>
      @model.set 'username', res.username

      # stashing the username in localStorage for the
      # case when Persona comebacks from an email link
      # with no trace of the previous username
      localStorage.setItem 'username', res.username

      @$el.trigger 'check', -> app.execute 'show:signup:step2'
    .fail (err)=>
      _.log err.responseJSON, 'invalidUsername'
      @invalidUsername(err)

  invalidUsername: usernameTests.invalidUsername