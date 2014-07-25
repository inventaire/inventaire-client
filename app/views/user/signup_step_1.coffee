module.exports = class SignupStep1 extends Backbone.Marionette.ItemView
  tagName: 'div'
  template: require 'views/user/templates/signup_step1'
  onShow: -> app.commands.execute 'modal:open'
  ui:
    check: '.check'
  behaviors:
    SuccessCheck: {}

  events:
    'click #verifyUsername': 'verifyUsername'
    'keydown #username': 'closeAlertBoxIfVisible'

  verifyUsername: (e)->
    console.log 'verifyUsername'
    e.preventDefault()
    username = $('#username').val()
    $.post('/auth/username', {username: username})
    .then (res)=>
      @model.set('username', res.username)
      @$el.trigger 'check', -> app.commands.execute 'signup:validUsername'
    .fail(@invalidUsername)

  invalidUsername: (err)->
    errMessage = err.responseJSON.status_verbose || "invalid"
    close = "<a href='#' class='close'>&times;</a>"
    $('#usernamePicker .input-alert').addClass('alert-box')
    .hide().slideDown(200).html(errMessage + close)


  closeAlertBoxIfVisible: ->
    alertbox = @$el.find('.input-alert')
    if alertbox.is(':visible')
      alertbox.find('.close').trigger('click')
