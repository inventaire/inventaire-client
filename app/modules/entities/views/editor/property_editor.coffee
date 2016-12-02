isLoggedIn = require './lib/is_logged_in'
creationParials = require 'modules/entities/lib/creation_partials'

editors =
  entity: require './entity_value_editor'
  'fixed-entity': require './fixed_entity'
  string: require './string_value_editor'
  'simple-day': require './simple_day_value_editor'
  'positive-integer': require './positive_integer_value_editor'

module.exports = Marionette.CompositeView.extend
  className: ->
    specificClass = 'property-editor-' + @model.get('editorType')
    return "property-editor #{specificClass}"

  template: require './templates/property_editor'
  getChildView: -> editors[@model.get('editorType')]
  childViewContainer: '.values'

  behaviors:
    # May be required by customAdd creation partials
    AlertBox: {}

  initialize: ->
    @collection = @model.values
    unless @model.get 'multivalue'
      @listenTo @collection, 'add remove', @updateAddValueButton.bind(@)

    @property = @model.get 'property'
    @customAdd = creationParials[@property]

  serializeData: ->
    attrs = @model.toJSON()
    if @customAdd
      attrs.customAdd = true
      attrs.creationPartial = 'entities:editor:' + @customAdd.partial
      attrs.creationPartialData = @customAdd.partialData()
    else
      attrs.canAddValues = @canAddValues()
    return attrs

  canAddValues: -> @model.get('multivalue') or @collection.length is 0

  onRender: ->
    if @customAdd?.focusTarget
      focus = => @$el.find(@customAdd.focusTarget).focus()
      # Somehow required to let the time to thing to get in place
      setTimeout focus, 200

  events:
    'click .addValue': 'addValue'
    'click .creationPartial a': 'dispatchCreationPartialClickEvents'

  ui:
    addValueButton: '.addValue'

  addValue: (e)->
    if isLoggedIn() then @collection.addEmptyValue()
    # Prevent parent views including the same 'click .addValue': 'addValue'
    # event listener to be triggered
    e.stopPropagation()

  updateAddValueButton: ->
    if @collection.length is 0 then @ui.addValueButton.show()
    else @ui.addValueButton.hide()

  dispatchCreationPartialClickEvents: (e)->
    { id } = e.currentTarget
    @customAdd.clickEvents[id]?(@, @model.entity, e)
