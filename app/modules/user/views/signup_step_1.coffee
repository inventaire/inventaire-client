module.exports = class SignupStep1 extends Backbone.Marionette.ItemView
  tagName: 'div'
  template: require './templates/signup_step1'
  behaviors:
    AlertBox: {}
    SuccessCheck: {}

  serializeData: ->
    attrs =
      usernamePicker:
        nameBase: 'username'
        special: true
        field:
          value: @model.get('username')
        button:
          text: _.i18n 'Validate'
    return _.extend attrs, @model.toJSON()


  onShow: ->
    app.execute 'foundation:reload'
    app.execute 'bg:book:toggle'

  onDestroy: ->  app.execute 'bg:book:toggle'

  events:
    'click #usernameButton': 'verifyUsername'

  verifyUsername: (e)->
    username = $('#usernameField').val()
    if username is ''
      @invalidUsername _.i18n "'username' can't be empty"
    else if requestedUsername.length > 20
      @invalidUsername _.i18n "username should be 20 character maximum"
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
    errMessage = _.i18n (err.responseJSON?.status_verbose or "invalid username")
    @$el.trigger 'alert', {message: errMessage}