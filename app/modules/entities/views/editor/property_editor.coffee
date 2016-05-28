isLoggedIn = require './lib/is_logged_in'

module.exports = Marionette.CompositeView.extend
  className: 'property-editor'
  template: require './templates/property_editor'
  childView: require './value_editor'
  childViewContainer: '.values'
  initialize: ->
    @collection = @model.values

  events:
    'click #addValue': 'addValue'

  addValue: ->
    if isLoggedIn() then @collection.addEmptyValue()
