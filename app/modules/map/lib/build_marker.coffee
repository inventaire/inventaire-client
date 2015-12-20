userMarker = require '../views/templates/user_marker'
customIcon = require './custom_icon'

markers =
  user: (params)->
    { model } = params
    { lat, lng } = model.getPosition()
    html = userMarker model.toJSON()
    icon = customIcon html
    marker = L.marker [lat, lng], {icon: icon}
    return marker

  circle: (params)->
    { latLng, metersRadius } = params
    metersRadius ?= 200
    return L.circle latLng, metersRadius

module.exports = (params)->
  { markerType } = params
  return markers[markerType] params
