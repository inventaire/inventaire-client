UserCommons = require './user_commons'

module.exports = UserCommons.extend
  isMainUser: false
  initialize: ->
    @setPathname()

  serializeData: ->
    attrs = @toJSON()
    relationStatus = attrs.status
    # converting the status into a boolean for templates
    attrs[relationStatus] = true
    # nonRelationGroupUser status have the same behavior as public users for views
    if relationStatus is 'nonRelationGroupUser'
      attrs.public = true
    attrs.inventoryLength = @inventoryLength()
    return attrs

  inventoryLength: ->
    if @itemsFetched then app.request 'inventory:user:length', @id
