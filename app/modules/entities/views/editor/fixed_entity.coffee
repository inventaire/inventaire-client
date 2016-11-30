module.exports = Marionette.ItemView.extend
  template: require './templates/fixed_entity'
  className: 'fixed-entity value-editor-commons'

  initialize: ->
    @lazyRender = _.LazyRender @

  serializeData: ->
    attr = @model.toJSON()
    attr.valueEntity = @valueEntityData()
    attr.value = attr.valueEntity?.label or attr.value
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
