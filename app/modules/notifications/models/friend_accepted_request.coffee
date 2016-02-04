Notification = require './notification'

module.exports = Notification.extend
  initSpecific: ->
    @grabAttributeModel 'user'

  serializeData: ->
    attrs = @toJSON()
    attrs.username = @user?.get 'username'
    attrs.picture = @user?.get 'picture'
    attrs.pathname = "/inventory/#{attrs.username}"
    return attrs
