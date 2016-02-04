Notification = require './notification'

module.exports = Notification.extend
  initSpecific:->
    @grabAttributeModel 'user'
    @grabAttributeModel 'item'

  serializeData: ->
    attrs = @toJSON()
    attrs.username = @user?.get 'username'
    attrs.picture = @user?.get 'picture'
    if @item?
      [ title, entity ] = @item.gets 'title', 'entity'
      attrs.pathname = "/inventory/#{attrs.username}/#{entity}"
      attrs.title = title
    return attrs
