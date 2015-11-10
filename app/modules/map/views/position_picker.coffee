map_ = require '../lib/map'
forms_ = require 'modules/general/lib/forms'
error_ = require 'lib/error'
{ startLoading, stopLoading, Check } = require 'modules/general/plugins/behaviors'

module.exports = Marionette.ItemView.extend
  template: require './templates/position_picker'
  className: 'positionPicker'
  behaviors:
    AlertBox: {}
    Loading: {}
    SuccessCheck: {}

  events:
    'click #validatePosition': 'validatePosition'
    'click #removePosition': 'removePosition'

  initialize: ->
    { user } = app
    @hasPosition = user.hasPosition()
    @position = user.getPosition()

  serializeData: ->
    hasPosition: @hasPosition
    position: @position

  onShow: ->
    app.execute 'modal:open', 'large'
    @initMap()

  initMap: ->
    if @hasPosition then @_initMap @position
    else
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

  validatePosition: -> @_updatePosition @getPosition(), '#validatePosition'
  removePosition: -> @_updatePosition null, '#removePosition'
  _updatePosition: (newValue, selector)->
    startLoading.call @, selector

    app.request 'user:update',
      attribute: 'position'
      value: @position = newValue
      selector: '#validatePosition'
    .then stopLoading.bind(@)
    .then Check.call(@, '_updatePosition', @close.bind(@))
    .catch error_.Complete('.alertBox')
    .catch forms_.catchAlert.bind(null, @)

  close: -> app.execute 'modal:close'

updateMarker = (marker, e)->
  { lat, lng } = e.target.getCenter()
  map_.updateMarker marker, lat, lng
