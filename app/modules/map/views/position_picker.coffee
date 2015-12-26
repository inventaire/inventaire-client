map_ = require '../lib/map'
forms_ = require 'modules/general/lib/forms'
error_ = require 'lib/error'
{ startLoading, stopLoading, Check } = require 'modules/general/plugins/behaviors'
containerId = 'positionPickerMap'

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
    { model } = @options
    if model?
      @hasPosition = model.hasPosition()
      @position = model.getPosition()
    else
      @hasPosition = false
      @position = null

  serializeData: ->
    hasPosition: @hasPosition
    position: @position

  onShow: ->
    app.execute 'modal:open', 'large'
    # let the time to the modal to be fully open
    # so that the map can be drawned correctly
    setTimeout @initMap.bind(@), 500

  initMap: ->
    if @hasPosition then @_initMap @position
    else
      map_.getCurrentPosition containerId
      .then @_initMap.bind(@)

  _initMap: (coords)->
    { lat, lng, zoom } = coords
    map = map_.draw
      containerId: containerId
      latLng: [lat, lng]
      zoom: zoom
      cluster: false

    @marker = map.addMarker
      markerType: 'circle'
      latLng: [lat, lng]

    map.on 'move', updateMarker.bind(null, @marker)

  getPosition: ->
    { lat, lng } = @marker._latlng
    return [ lat, lng ]

  validatePosition: -> @_updatePosition @getPosition(), '#validatePosition'
  removePosition: -> @_updatePosition null, '#removePosition'
  _updatePosition: (newCoords, selector)->
    startLoading.call @, selector

    @position = newCoords

    # allow @options.resolve not to return a promise
    _.preq.start()
    .then @options.resolve.bind(null, newCoords, selector)
    .then stopLoading.bind(@)
    .then Check.call(@, '_updatePosition', @close.bind(@))
    .catch error_.Complete('.alertBox')
    .catch forms_.catchAlert.bind(null, @)

  close: -> app.execute 'modal:close'

updateMarker = (marker, e)->
  { lat, lng } = e.target.getCenter()
  map_.updateMarker marker, lat, lng
