isLoggedIn = require './lib/is_logged_in'

editors =
  entity: require './value_editor'
  'fixed-entity': require './fixed_entity'
  string: require './string_value_editor'

module.exports = Marionette.CompositeView.extend
  className: ->
    specificClass = 'property-editor-' + @model.get('editorType')
    return "property-editor #{specificClass}"

  template: require './templates/property_editor'
  getChildView: -> editors[@model.get('editorType')]
  childViewContainer: '.values'
  initialize: ->
    @collection = @model.values
    unless @model.get 'multivalue'
      @listenTo @collection, 'add remove', @updateAddValueButton.bind(@)

  serializeData: ->
    attrs = @model.toJSON()
    attrs.canAddValues = @canAddValues()
    return attrs

  canAddValues: -> @model.get('multivalue') or @collection.length is 0

  events:
    'click .addValue': 'addValue'

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
