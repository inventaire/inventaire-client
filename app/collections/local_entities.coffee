Entities = require 'collections/entities'

module.exports = class LocalEntities extends Entities
  initialize: -> @fetch()
  localStorage: new Backbone.LocalStorage 'Entities'
  hardReset: ->
    localStorage.clear()
    @_reset()