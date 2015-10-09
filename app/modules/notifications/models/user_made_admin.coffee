Notification = require './notification'

module.exports = Notification.extend
  initSpecific:->
    @groupId = @get 'data.group'
    app.request('waitForData').then @grabGroup.bind(@)

  grabGroup:->
    @reqGrab 'get:group:model', @groupId, 'group'

  serializeData: ->
    attrs = @commonData()
    attrs.pathname = "/network/groups/#{@groupId}"
    if @group?
      attrs.picture = @group.get 'picture'
      attrs.groupName = @group.get 'name'
    return attrs
