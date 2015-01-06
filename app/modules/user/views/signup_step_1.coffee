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

  verifyUsername: (e)->
    username = @ui.username.val()
    if username is ''
      @invalidUsername "'username' can't be empty"
    else if username.length > 20
      @invalidUsername "username should be 20 character maximum"
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

  invalidUsername: (err)=>
    if _.isString err then errMessage = err
    else errMessage = err.responseJSON?.status_verbose or "invalid username"
    @$el.trigger 'alert', {message: _.i18n(errMessage)}