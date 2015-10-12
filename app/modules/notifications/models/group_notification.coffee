# used for: userMadeAdmin, groupUpdate (name, description)

Notification = require './notification'
{ escapeExpression } = Handlebars

module.exports = Notification.extend
  initSpecific:->
    @groupId = @get 'data.group'
    app.request('waitForData').then @grabGroup.bind(@)

  grabGroup:->
    @reqGrab 'get:group:model', @groupId, 'group'

  # groupCommonData: ->
  serializeData: ->
    attrs = @commonData()
    # _.extend attrs, attrs.data
    attrs = getUpdateValue attrs
    attrs.pathname = "/network/groups/#{@groupId}"
    if @group?
      attrs.picture = @group.get 'picture'
      attrs.groupName = @group.getEscapedName()
      attrs.text = getText attrs.type, attrs.data.attribute
      attrs.previousValue
    return attrs

getText = (type, attribute)->
  if attribute? then texts[type][attribute]
  else texts[type]

texts =
  userMadeAdmin: 'user_made_admin'
  groupUpdate:
    name: 'group_update_name'
    description: 'group_update_description'

getUpdateValue = (attrs)->
  { previousValue, newValue } = attrs.data
  if previousValue?
    attrs.previousValue = escapeExpression previousValue
    attrs.newValue = escapeExpression newValue
  return attrs
