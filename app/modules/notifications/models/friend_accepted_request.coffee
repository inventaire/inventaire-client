Notification = require './notification'

module.exports = Notification.extend
  initSpecific:->
    app.request('waitForData').then @grabUser.bind(@)

  grabUser: ->
    user = @get 'data.user'
    @reqGrab 'get:user:model', user, 'user'

  serializeData: ->
    attrs = @commonData()
    attrs.picture = @getUserPicture()
    attrs.pathname = "/inventory/#{attrs.username}"
    return attrs
