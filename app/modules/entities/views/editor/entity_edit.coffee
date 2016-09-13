TitleEditor = require './title_editor'
PropertiesEditor = require './properties_editor'
propertiesCollection = require 'modules/entities/lib/editor/properties_collection'
createEntities = require 'modules/entities/lib/create_entities'
SubEntitiesEditor = require './sub_entities_editor'

module.exports = Marionette.LayoutView.extend
  id: 'entityEdit'
  template: require './templates/entity_edit'
  regions:
    title: '.title'
    claims: '.claims'
    subentities: '.subentities'

  initialize: ->
    { @subeditor } = @options
    @properties = propertiesCollection @model
    { @childrenClaimProperty } = @model

  onShow: ->
    unless @model.type is 'edition'
      @title.show new TitleEditor { @model }

    @claims.show new PropertiesEditor
      collection: @properties
      propertiesShortlist: @model.propertiesShortlist

    if @childrenClaimProperty?
      collection = @model.subentities[@childrenClaimProperty]
      @subentities.show new SubEntitiesEditor
        collection: collection
        property: @childrenClaimProperty
        parent: @model

  serializeData: ->
    attrs = @model.toJSON()
    attrs.subeditor = @subeditor
    attrs.creating = @model.creating
    attrs.childrenClaimProperty = @childrenClaimProperty
    return attrs

  events:
    'click .createAndShowEntity': 'createAndShowEntity'
    'click .createAndAddEntity': 'createAndAddEntity'

  createAndShowEntity: ->
    @model.create()
    .then app.Execute('show:entity:from:model')

  createAndAddEntity: ->
    @model.create()
    .then app.Execute('show:entity:add:from:model')
