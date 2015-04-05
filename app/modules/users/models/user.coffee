Filterable = require 'modules/general/models/filterable'

module.exports = User = Filterable.extend
  asMatchable: ->
    [
      @get('username')
    ]

  serializeData: ->
    attrs = @toJSON()
    attrs.pathname = "/inventory/#{attrs.username}"
    relationStatus = attrs.status
    # converting the status into a boolean for templates
    attrs[relationStatus] = true
    if relationStatus is 'friends'
      attrs.inventoryLength = app.request 'inventory:user:length', @id
    return attrs
