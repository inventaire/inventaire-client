module.exports = class SignupStep1 extends Backbone.Marionette.ItemView
  tagName: 'div'
  template: require 'views/user/templates/signup_step1'
  onShow: -> app.commands.execute 'modal:open'
  behaviors:
    AlertBox: {}
    SuccessCheck: {}

  serializeData: -> return {header: _.i18n('Step 1: Choose a username'), buttonLabel: _.i18n('Validate')}

  events:
    'click #verifyUsername': 'verifyUsername'

  verifyUsername: (e)->
    username = $('#username').val()
    $.post app.API.auth.username, {username: username}
    .then (res)=>
      @model.set 'username', res.username
      @$el.trigger 'check', -> app.commands.execute 'signup:validUsername'
    .fail (err)=>
      @invalidUsername(err)

  invalidUsername: (err)=>
    errMessage = _.i18n (err.responseJSON.status_verbose || "invalid username")
    @$el.trigger 'alert', {message: errMessage}