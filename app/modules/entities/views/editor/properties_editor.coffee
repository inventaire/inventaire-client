module.exports = Marionette.CompositeView.extend
  template: require './templates/properties_editor'
  childView: require './property_editor'
  childViewContainer: '.properties'
  initialize: ->
    _.log @collection, 'properties collection'
