Filterable = require 'modules/general/models/filterable'

module.exports = class User extends Filterable
  asMatchable: ->
    [
      @get('username')
    ]

  serializeData: ->
    attrs = @toJSON()
    relationStatus = attrs.status
    # converting the status into a boolean for templates
    attrs[relationStatus] = true
    if relationStatus is 'friends'
      attrs.inventoryLength = app.request 'inventory:user:length', @id
    return attrs
