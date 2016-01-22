Filterable = require './filterable'

# Extending Filterable as the models needing position feature
# happen to also need filterable features
module.exports = Filterable.extend
  hasPosition: -> @has 'position'
  getCoords: ->
    latLng = @get 'position'
    if latLng?
      [ lat, lng ] = latLng
      return { lat: lat, lng: lng }
    else
      return {}

  getLatLng: ->
    # Create a L.LatLng only once
    # Update it when position update (only required for the main user)
    if @_latLng? then return @_latLng
    else @setLatLng()

  setLatLng: ->
    if @hasPosition()
      [ lat, lng ] = @get 'position'
      return @_latLng = new L.LatLng lat, lng
    else
      return @_latLng = null
