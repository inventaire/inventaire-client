module.exports = Backbone.Marionette.ItemView.extend
  tagName: 'div'
  className: 'validEmailConfirmation'
  template: require './templates/valid_email_confirmation'
  behaviors:
    Loading: {}

  events:
    'click .showHome, .showLogin ': -> app.execute 'modal:close'
    'click #emailConfirmationRequest': 'emailConfirmationRequest'

  onShow: ->  app.execute('modal:open')

  serializeData: ->
    validEmail: @options.validEmail
    loggedIn: app.user.loggedIn

  emailConfirmationRequest: ->
    @$el.trigger 'loading'
    app.request 'email:confirmation:request'
    .then emailSent
    .catch emailFail.bind(@)

emailSent = -> app.execute 'modal:close'
emailFail = -> @$el.trigger 'somethingWentWrong'
