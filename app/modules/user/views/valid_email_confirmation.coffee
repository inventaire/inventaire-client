module.exports = Backbone.Marionette.ItemView.extend
  tagName: 'div'
  className: 'validEmailConfirmation'
  template: require './templates/valid_email_confirmation'
  events:
    'click .button': -> app.execute 'modal:close'

  onShow: ->  app.execute('modal:open')

  serializeData: ->
    validEmail: @options.validEmail is "true"
    loggedIn: app.user.loggedIn
