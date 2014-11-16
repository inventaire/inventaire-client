Filterable = require 'models/filterable'

module.exports = class User extends Filterable
  asMatchable: ->
    [
      @get('username')
    ]