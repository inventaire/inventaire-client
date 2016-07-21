TitleEditor = require './title_editor'
PropertiesEditor = require './properties_editor'
propertiesCollection = require 'modules/entities/lib/editor/properties_collection'

module.exports = Marionette.LayoutView.extend
  id: 'entityEdit'
  template: require './templates/entity_edit'
  regions:
    title: '.title'
    claims: '.claims'

  initialize: ->
    { @subeditor } = @options
    @properties = propertiesCollection @model
    { @childrenClaimProperty } = @model

  onShow: ->
    unless @model.type is 'edition'
      @title.show new TitleEditor { model: @model }

    @claims.show new PropertiesEditor
      collection: @properties
      propertiesShortlist: @model.propertiesShortlist
