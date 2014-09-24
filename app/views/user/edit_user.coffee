module.exports = class EditUser extends Backbone.Marionette.ItemView
  tagName: 'div'
  template: require 'views/user/templates/edit_user'
  behaviors:
    AlertBox: {}
    SuccessCheck: {}
    ConfirmationModal: {}

  initialize: ->
    @listenTo app.vent, 'i18n:reset', ->
      @render()
      # can't be triggered the 'normal' way as the page is
      # re-rendered when the promise is fulfilled
      $('#languagePicker').trigger('check')

  serializeData: ->
    attrs =
      buttonLabel: _.i18n 'Change Username'
      languages: Lang
    attrs.currentLanguages = attrs.languages[app.user.get('language')]
    _.extend attrs, @model.toJSON()
    return attrs

  events:
    'click a#verifyUsername': 'verifyUsername'
    'change select#languagePicker': 'changeLanguage'

  verifyUsername: (username)=>
    requestedUsername = $('#username').val()
    if requestedUsername == app.user.get 'username'
      @invalidUsername _.i18n "that's already your username"
    else if requestedUsername is ''
      @invalidUsername _.i18n "'username' can't be empty"
    else
      $.post app.API.auth.username, {username: requestedUsername}
      .then (res)=> @confirmUsernameChange(res.username)
      .fail(@invalidUsername)

  confirmUsernameChange: (requestedUsername)=>
    args =
      requestedUsername: requestedUsername
      currentUsername: app.user.get 'username'
      model: @model
    @$el.trigger 'askConfirmation',
      confirmationText: _.i18n "Your current username is <strong>#{args.currentUsername}</strong><br>
        Are you sure you want to change for <strong>#{args.requestedUsername}</strong>?"
      warningText: _.i18n "You shouldn't change your username too often, as it's the way others can find you"
      actionCallback: (args)=>
        params = {attribute: 'username', value: args.requestedUsername}
        return app.request('user:update', params)
      actionArgs: args

  invalidUsername: (err)=>
    if _.isString err
      errMessage = err
    else
      errMessage = _.i18n(err.responseJSON.status_verbose || "invalid username")
    @$el.trigger 'alert', {message: errMessage}

  changeLanguage: (e)->
    lang = e.target.value
    if lang isnt app.user.get 'language'
      app.request 'user:update',
        attribute:'language'
        value: e.target.value
        selector: '#languagePicker'