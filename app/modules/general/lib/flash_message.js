intervalId = null
active = false

module.exports = ->

  showNetworkError = =>
    if active then return
    active = true
    @ui.flashMessage.addClass 'active'
    unless intervalId? then intervalId = setInterval checkState, 1000

  hideNetworkError = =>
    unless active then return
    active = false
    @ui.flashMessage.removeClass 'active'
    if intervalId?
      clearInterval intervalId
      intervalId = null

  checkState = ->
    _.preq.get app.API.tests
    .then hideNetworkError

  app.commands.setHandlers
    'flash:message:show:network:error': showNetworkError
