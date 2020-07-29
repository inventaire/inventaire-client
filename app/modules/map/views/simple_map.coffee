map_ = require '../lib/map'
containerId = 'simpleMap'

module.exports = Marionette.ItemView.extend
  template: require './templates/simple_map'

  initialize: ->
    { @models } = @options

  onShow: ->
    app.execute 'modal:open', 'large', @options.focus
    # let the time to the modal to be fully open
    # so that the map can be drawned correctly
    @setTimeout @initMap.bind(@), 500

  initMap: ->
    bounds = @models.map getPosition

    map = map_.draw
      containerId: containerId
      bounds: bounds
      cluster: false

    map_.showModelsOnMap map, @models

getPosition = (model)-> model.get('position') or model.position
