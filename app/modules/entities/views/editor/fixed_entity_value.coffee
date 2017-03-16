module.exports = Marionette.ItemView.extend
  template: require './templates/fixed_entity_value'
  className: 'fixed-entity-value fixed-value value-editor-commons'

  initialize: ->
    @lazyRender = _.LazyRender @

  serializeData: ->
    attrs = @model.toJSON()
    attrs.valueEntity = @valueEntityData()
    attrs.value = attrs.valueEntity?.label or attrs.value
    if attrs.valueEntity?
      hasIdentifierTooltipLinks = attrs.valueEntity.type? or attrs.valueEntity.wikidata?
      attrs.valueEntity.hasIdentifierTooltipLinks = hasIdentifierTooltipLinks
      attrs.valueEntity.contrast = true
    return attrs

  valueEntityData: ->
    { valueEntity } = @model
    if valueEntity? then valueEntity.toJSON()

  onShow: ->
    @listenTo @model, 'grab', @onGrab.bind(@)

  onGrab: ->
    if @model.valueEntity?
      @listenToOnce @model.valueEntity, 'change:image', @lazyRender.bind(@)

    @lazyRender()
