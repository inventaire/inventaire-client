LocalEntities = require 'collections/local_entities'

module.exports = class TemporaryEntities extends LocalEntities
  localStorage: new Backbone.LocalStorage 'TmpEnt'