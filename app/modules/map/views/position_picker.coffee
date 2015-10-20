map_ = require '../lib/map'
forms_ = require 'modules/general/lib/forms'
error_ = require 'lib/error'
behaviorsPlugin = require 'modules/general/plugins/behaviors'

module.exports = Marionette.ItemView.extend
  template: require './templates/position_picker'
  className: 'positionPicker'
  behaviors:
    AlertBox: {}
    Loading: {}

  events:
    'click #validatePosition': 'validatePosition'

  onShow: ->
    app.execute 'modal:open', 'large'
    @initMap()

  initMap: ->
    map_.getCurrentPosition()
    .then @_initMap.bind(@)

  _initMap: (coords)->
    { lat, lng, zoom } = coords
    map = map_.draw 'positionPickerMap', lat, lng, zoom

    @marker = marker = map_.addCircleMarker map, lat, lng
    map.on 'move', updateMarker.bind(null, marker)

  getPosition: ->
    { lat, lng } = @marker._latlng
    return [ lat, lng ]

  validatePosition: ->
    behaviorsPlugin.startLoading.call @, '#validatePosition'
    app.request 'user:update',
      attribute: 'position'
      value: @getPosition()
      selector: '#validatePosition'
    .then @close.bind(@)
    .catch error_.Complete('.alertBox')
    .catch forms_.catchAlert.bind(null, @)

  close: -> app.execute 'modal:close'

updateMarker = (marker, e)->
  { lat, lng } = e.target.getCenter()
  map_.updateMarker marker, lat, lng
