# REQUIRED:
# - ConfirmationModal behavior

events =
  'click .cancel': 'cancel'
  'click .discard': 'discard'
  'click .accept': 'accept'
  'click .request': 'send'
  'click .unfriend': 'unfriend'

confirmUnfriend = ->
  confirmationText = _.i18n 'unfriend_confirmation',
    username: @model.get 'username'

  @$el.trigger 'askConfirmation',
    confirmationText: confirmationText
    warningText: null
    action: app.request.bind(app, 'unfriend', @model)

handlers =
 cancel: -> app.request 'request:cancel', @model
 discard: -> app.request 'request:discard', @model
 accept: -> app.request 'request:accept', @model
 send: -> app.request 'request:send', @model
 unfriend: confirmUnfriend


module.exports = _.BasicPlugin events, handlers
