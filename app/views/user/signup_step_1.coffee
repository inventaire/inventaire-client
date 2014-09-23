module.exports = class SignupStep1 extends Backbone.Marionette.ItemView
  tagName: 'div'
  template: require 'views/user/templates/signup_step1'
  # onShow: -> app.execute 'modal:open'
  behaviors:
    AlertBox: {}
    SuccessCheck: {}

  serializeData: ->
    attrs =
      header: _.i18n('Step 1: Choose a username')
      buttonLabel: _.i18n('Validate')
    return _.extend attrs, @model.toJSON()

  events:
    'click #verifyUsername': 'verifyUsername'

  verifyUsername: (e)->
    username = $('#username').val()
    if username is ''
      @invalidUsername _.i18n "'username' can't be empty"
    else
      $.post(app.API.auth.username, {username: username})
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
      .done()

  invalidUsername: (err)=>
    errMessage = _.i18n (err.responseJSON?.status_verbose || "invalid username")
    @$el.trigger 'alert', {message: errMessage}