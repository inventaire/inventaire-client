Filterable = require 'modules/general/models/filterable'

module.exports = class User extends Filterable
  asMatchable: ->
    [
      @get('username')
    ]