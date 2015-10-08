Notification = require './notification'

module.exports = Notification.extend
  serializeData: ->
    attrs = @commonData()
    attrs.picture = @getUserPicture()
    attrs.pathname = "/inventory/#{attrs.username}"
    return attrs
