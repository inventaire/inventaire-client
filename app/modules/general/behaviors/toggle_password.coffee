# requires the view to have a ui.password defined

module.exports = Marionette.Behavior.extend
  ui:
    showPassword: '#showPassword'

  initialize: ->
    @passwordShown = false

  events:
    'click #showPassword': 'togglePassword'

  togglePassword: ->
    if @passwordShown then @passwordType 'password'
    else @passwordType 'text'

  passwordType: (type)->
    @view.ui.password.attr 'type', type
    @ui.showPassword.toggleClass 'active'
    @passwordShown = not @passwordShown