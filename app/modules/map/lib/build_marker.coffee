userMarker = require '../views/templates/user_marker'
groupMarker = require '../views/templates/group_marker'
customIcon = require './custom_icon'

ObjectMarker = (markerBuilder)->
  objectMarker = (params)->
    { model } = params
    { lat, lng } = model.getPosition()
    html = markerBuilder model.toJSON()
    icon = customIcon html
    marker = L.marker [lat, lng], {icon: icon}
    return marker

markers =
  user: ObjectMarker userMarker
  group: ObjectMarker groupMarker
  circle: (params)->
    { latLng, metersRadius } = params
    metersRadius ?= 200
    return L.circle latLng, metersRadius

module.exports = (params)->
  { markerType } = params
  return markers[markerType] params
