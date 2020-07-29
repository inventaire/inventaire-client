userMarker = require '../views/templates/user_marker'
groupMarker = require '../views/templates/group_marker'
itemMarker = require '../views/templates/item_marker'
customIcon = require './custom_icon'

objectMarker = (markerBuilder)-> (params)->
  { model } = params
  { lat, lng } = model.getCoords()
  html = markerBuilder model.serializeData()
  icon = customIcon html
  marker = L.marker [ lat, lng ], { icon }
  return marker

markers =
  user: objectMarker userMarker
  group: objectMarker groupMarker
  item: objectMarker itemMarker
  circle: (params)->
    { latLng, metersRadius } = params
    metersRadius ?= 200
    return L.circle latLng, metersRadius

module.exports = (params)->
  { markerType } = params
  return markers[markerType] params
