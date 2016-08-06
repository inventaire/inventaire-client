module.exports = Marionette.CompositeView.extend
  template: require './templates/properties_editor'
  childView: require './property_editor'
  childViewContainer: '.properties'
  initialize: ->
    _.log @collection, 'properties collection'
    { propertiesShortlist } = @options

    if propertiesShortlist
      # set propertiesShortlist to display only a subset of properties by default
      @filter = (child, index, collection)->
        return child.get('property') in propertiesShortlist
