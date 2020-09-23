leafletLite = require './leaflet_lite'

module.exports =
  # Coordinates are returned in decimal degrees
  # There is no need to keep more than 4 decimals, cf https://xkcd.com/2170/
  # See https://developer.mozilla.org/en-US/docs/Web/API/GeolocationCoordinates
  truncateDecimals: (degree)-> Math.round(degree * 10000) / 10000

  # a, b MUST be { lat, lng } coords objects
  distanceBetween: (a, b)->
    _.types arguments, 'objects...'
    # return the distance in kilometers
    return leafletLite.distance(a, b) / 1000
