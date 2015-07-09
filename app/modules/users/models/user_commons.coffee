Filterable = require 'modules/general/models/filterable'

module.exports = Filterable.extend
  inventoryLength: ->
    if @itemsFetched then app.request 'inventory:user:length', @id
  setPathname: ->
    username = @get('username')
    @set 'pathname', "/inventory/#{username}"
