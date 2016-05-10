module.exports = Marionette.CompositeView.extend
  className: 'property-editor'
  template: require './templates/property_editor'
  childView: require './value_editor'
  childViewContainer: '.values'
  initialize: ->
    @collection = @model.values
