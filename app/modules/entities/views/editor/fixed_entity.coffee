module.exports = Marionette.ItemView.extend
  template: require './templates/fixed_entity'
  className: 'fixed-entity'

  initialize: ->
    @lazyRender = _.LazyRender @

  serializeData: ->
    attr = @model.toJSON()
    attr.valueEntity = @valueEntityData()
    attr.value = attr.valueEntity?.label or attr.value
    if attr.valueEntity?
      attr.valueEntity.hasIdentifierTooltipLinks = attr.valueEntity.type? or attr.valueEntity.wikidata?
    return attr

  valueEntityData: ->
    { valueEntity } = @model
    if valueEntity? then valueEntity.toJSON()

  onShow: ->
    @listenTo @model, 'grab', @onGrab.bind(@)

  onGrab: ->
    if @model.valueEntity?
      @listenToOnce @model.valueEntity, 'change:image', @lazyRender.bind(@)

    @lazyRender()
