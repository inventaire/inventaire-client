map_ = require '../lib/map'
containerId = 'simpleMap'

module.exports = Marionette.ItemView.extend
  template: require './templates/simple_map'

  initialize: ->
    { @models } = @options

  behaviors:
    PreventDefault: {}

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

  events:
    'click .userMarker a': 'showUser'
    'click .itemMarker a': 'showItem'

  showUser: (e)->
    if _.isOpenedOutside e then return
    e.stopPropagation()
    userId = e.currentTarget.attributes['data-user-id'].value
    app.execute 'show:inventory:user', userId

  showItem: (e)->
    if _.isOpenedOutside e then return
    e.stopPropagation()
    itemId = e.currentTarget.attributes['data-item-id'].value
    app.execute 'show:item:byId', itemId

getPosition = (model)-> model.get('position') or model.position
