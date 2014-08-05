module.exports = class EditUser extends Backbone.Marionette.ItemView
  tagName: 'div'
  template: require 'views/user/templates/edit_user'
  behaviors:
    AlertBox: {}
    SuccessCheck: {}
    ConfirmationModal: {}

  serializeData: -> return _.extend {buttonLabel: 'Change Username'}, @model.toJSON

  events:
    'click #verifyUsername': 'verifyUsername'

  verifyUsername: (username)=>
    requestedUsername = $('#username').val()
    if requestedUsername == app.user.get 'username'
      @invalidUsername "that's already your username"
    else
      $.post app.API.auth.username, {username: requestedUsername}
      .then (res)=> @confirmUsernameChange(res.username)
      .fail(@invalidUsername)

  confirmUsernameChange: (username)=>
    args =
      requestedUsername: username
      currentUsername: app.user.get 'username'
      model: @model
    @$el.trigger 'askConfirmation',
      confirmationText: "Your current username is <strong>#{args.currentUsername}</strong><br>
        Are you sure you want to change for <strong>#{args.requestedUsername}</strong>?"
      warningText: "You shouldn't change your username too often, as it's the way others can find you"
      actionCallback: (args)=>
        return app.request('user:update', {fieldName: 'username', value: args.requestedUsername})
      actionArgs: args

  invalidUsername: (err)=>
    if typeof err is 'string'
      errMessage = err
    else
      errMessage = err.responseJSON.status_verbose || "invalid username"
    @$el.trigger 'alert', {message: errMessage}