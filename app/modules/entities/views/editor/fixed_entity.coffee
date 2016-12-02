module.exports = Marionette.ItemView.extend
  template: require './templates/fixed_entity'
  className: 'fixed-entity value-editor-commons'

  initialize: ->
    @lazyRender = _.LazyRender @

  serializeData: ->
    attrs = @model.toJSON()
    attrs.valueEntity = @valueEntityData()
    attrs.value = attrs.valueEntity?.label or attrs.value
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
