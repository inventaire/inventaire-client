Notification = require './notification'

module.exports = Notification.extend
  initSpecific:-> @grabAttributesModels 'user', 'item'

  serializeData: ->
    attrs = @toJSON()
    attrs.username = @user?.get 'username'
    attrs.picture = @user?.get 'picture'
    if @item?
      [ title, pathname ] = @item.gets 'snapshot.entity:title', 'pathname'
      attrs.pathname = pathname
      attrs.title = title
    return attrs
