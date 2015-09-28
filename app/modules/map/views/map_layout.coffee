map_ = require '../lib/map'

module.exports = Marionette.LayoutView.extend
  template: require './templates/map_layout'
  id: 'mapLayout'
  initialize: ->

  onShow: ->
    { lat, lng, zoom } = @options.coordinates
    if lat? and lng?
      map_.draw 'map', lat, lng, zoom
    else
      navigator.geolocation.getCurrentPosition (position)->
        _.log position, 'position'
        { latitude, longitude} = position.coords
        map_.draw 'map', latitude, longitude, zoom

