Notification = require './notification'

module.exports = Notification.extend
  initSpecific:->
    app.request('waitForItems').then @grabItem.bind(@)

  grabItem: ->
    item = @get 'data.item'
    @reqGrab 'get:item:model', item, 'item'

  serializeData: ->
    attrs = @commonData()
    attrs.picture = @getUserPicture()
    if @item?
      [ title, entity ] = @item.gets 'title', 'entity'
      attrs.pathname = "/inventory/#{attrs.username}/#{entity}"
      attrs.title = title
    return attrs
