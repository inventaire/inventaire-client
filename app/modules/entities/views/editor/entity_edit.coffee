PropertiesEditor = require './properties_editor'
propertiesCollection = require 'modules/entities/lib/editor/properties_collection'

module.exports = Marionette.LayoutView.extend
  id: 'entityEdit'
  template: require './templates/entity_edit'
  regions:
    labels: '.labels'
    claims: '.claims'

  initialize: ->
    @properties = propertiesCollection @model

  onShow: ->
    @claims.show new PropertiesEditor { collection: @properties }
