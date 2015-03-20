# requires the view to have a ui.password defined

module.exports = Marionette.Behavior.extend
  ui:
    showPassword: '.showPassword'

  initialize: ->
    @passwordShown = false

  events:
    'click .showPassword': 'togglePassword'

  togglePassword: ->
    if @passwordShown then @passwordType 'password'
    else @passwordType 'text'

  passwordType: (type)->
    el = @view.ui.passwords or @view.ui.password
    el.attr 'type', type
    @ui.showPassword.toggleClass 'toggled'
    @passwordShown = not @passwordShown
