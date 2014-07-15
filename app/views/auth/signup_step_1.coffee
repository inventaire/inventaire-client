module.exports = class SignupStep1 extends Backbone.Marionette.ItemView
  tagName: 'div'
  template: require 'views/auth/templates/signup_step1'
  onShow: ->
    app.commands.execute 'modal:open'
  events:
    'click #verifyUsername': 'verifyUsername'
    'keydown #username': 'closeAlertBoxIfVisible'

  verifyUsername: (e)->
    e.preventDefault()
    username = $('#username').val()
    $.post('/auth/username', {username: username})
    .then (res)=>
      @model.set('username', res.username)
      @$el.find('.fa-check-circle').slideDown(300)
      cb = ()=>
        app.vent.trigger 'signup:validUsername'
        # new SignupStep2View {model: @model}
      setTimeout(cb, 500)
    .fail(@invalidUsername)

  invalidUsername: (err)->
    errMessage = err.responseJSON.status_verbose || "invalid"
    close = "<a href='#' class='close'>&times;</a>"
    $('#usernamePicker .alert-box').hide().slideDown(200).html(errMessage + close)


  closeAlertBoxIfVisible: ->
    alertbox = @$el.find('.alert-box')
    if alertbox.is(':visible')
      alertbox.find('.close').trigger('click')
