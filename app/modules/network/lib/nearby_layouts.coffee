map_ = require 'modules/map/lib/map'
{ updateRoute, updateRouteFromEvent } = map_

initMap = (params)->
  { query } = params
  solvePosition query
  .then drawMap.bind(null, params)
  .then initEventListners.bind(null, params)

solvePosition = (coords)->
  # priority is given to passed parameters
  { lat, lng, zoom } = coords
  if lat? and lng? then return _.preq.resolve coords

  # then to the user saved position
  { user } = app
  if user.hasPosition() then return _.preq.resolve user.getPosition()

  # finally a request for the user position is issued
  return map_.getCurrentPosition()

drawMap = (params, coords)->
  { lat, lng, zoom } = coords
  { showObjects, path } = params

  map = map_.draw 'map', lat, lng, zoom
  showObjects map, [lat, lng]

  # update the path after the tabs lazyrendered and updated the path
  fn = updateRoute.bind null, path, lat, lng, zoom
  setTimeout fn, 500

  _.type map, 'object'
  return map

initEventListners = (params, map)->
  _.type map, 'object'
  { path, onMoveend } = params
  map.on 'moveend', updateRouteFromEvent.bind(null, path)
  map.on 'moveend', onMoveend
  return map

module.exports =
  initMap: initMap
