module.exports = Marionette.CompositeView.extend
  className: 'properties-editor'
  template: require './templates/properties_editor'
  childView: require './property_editor'
  childViewContainer: '.properties'
  initialize: ->
    { propertiesShortlist } = @options
    @hasPropertiesShortlist = propertiesShortlist?

    if @hasPropertiesShortlist
      # set propertiesShortlist to display only a subset of properties by default
      @filter = (child, index, collection)->
        return child.get('property') in propertiesShortlist

  ui:
    showAllProperties: '#showAllProperties'

  events:
    'click #showAllProperties': 'showAllProperties'

  onShow: ->
    if @hasPropertiesShortlist then @ui.showAllProperties.show()

  showAllProperties: ->
    @filter = null
    @render()
    @ui.showAllProperties.hide()
