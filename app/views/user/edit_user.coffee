module.exports = class EditUser extends Backbone.Marionette.ItemView
  tagName: 'div'
  template: require 'views/user/templates/edit_user'
  # onShow: ->
  #   app.commands.execute 'modal:open'
  events:
    'click #verifyUsername': 'verifyUsername'
  #   'click #loginPersona': -> app.execute 'persona:login'

  verifyUsername: (e)->
    e.preventDefault()
    username = $('#username').val()
    if username == app.user.get('username')
      @invalidUsername("that's already your username")
    else
      $.post('/auth/username', {username: username})
      .then (res)=>
        @model.set('username', res.username)
        @$el.find('.fa-check-circle').slideDown(300).fadeOut(800)
        $('#verifyUsername').hide()
        $('#changeUsername').show()
        cb = ()=>
          console.log 'hey Im cb'
          # app.vent.trigger 'signup:validUsername'
          # new SignupStep2View {model: @model}
        setTimeout(cb, 500)
      .fail(@invalidUsername)

  invalidUsername: (err)->
    if err.responseJSON
      errMessage = err.responseJSON.status_verbose || "invalid"
    else
      errMessage = err
    close = "<a href='#' class='close'>&times;</a>"
    $('#usernamePicker .alert-box').hide().slideDown(200).html(errMessage + close)