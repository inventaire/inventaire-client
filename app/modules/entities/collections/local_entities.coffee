Entities = require './entities'

module.exports = class LocalEntities extends Entities
  localStorage: new Backbone.LocalStorage 'Entities'
  hardReset: ->
    localStorage.clear()
    @_reset()