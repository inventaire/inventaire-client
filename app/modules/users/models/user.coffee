Filterable = require 'modules/general/models/filterable'

module.exports = Filterable.extend
  initialize: ->
    username = @get 'username'
    @set 'pathname', "/inventory/#{username}"

  asMatchable: ->
    [
      @get('username')
    ]

  serializeData: ->
    attrs = @toJSON()
    relationStatus = attrs.status
    # converting the status into a boolean for templates
    attrs[relationStatus] = true
    # nonRelationGroupUser status have the same behavior as public users for views
    if relationStatus is 'nonRelationGroupUser'
      attrs.public = true
    if relationStatus is 'friends'
      attrs.inventoryLength = app.request 'inventory:user:length', @id
    return attrs
