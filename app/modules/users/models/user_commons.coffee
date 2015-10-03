Filterable = require 'modules/general/models/filterable'

module.exports = Filterable.extend
  setPathname: ->
    username = @get('username')
    @set 'pathname', "/inventory/#{username}"
  asMatchable: ->
    [
      @get('username')
    ]
