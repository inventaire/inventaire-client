errIcon = _.icon 'bolt'

# doc: https://developer.mozilla.org/en-US/docs/Web/API/Geolocation/getCurrentPosition
currentPosition = ->
  new Promise (resolve, reject)->
    unless navigator.geolocation?.getCurrentPosition?
      err = new Error 'getCurrentPosition isnt accessible'
      return reject err

    # getCurrentPosition throws PositionError s that aren't instanceof Error
    # thus the need to create a new error from it
    formattedReject = (err)->
      _.error err, 'currentPosition err'
      reject new Error(err.message or 'getCurrentPosition error')

    options =
      # The timeout option doesn't seem to have any effect
      timeout: 10*1000

    navigator.geolocation.getCurrentPosition resolve, formattedReject, options

normalizeCoords = (position)->
  { latitude, longitude } = position.coords
  return { lat: latitude, lng: longitude }

returnPlaceholderCoords = (err)->
  _.warn err, "couldn't obtain user's position: returning placeholder coordinates"
  return coords =
    lat: 46.232464793934994
    lng: 6.045017838478088
    zoom: 3

module.exports = (containerId)->
  currentPosition()
  .timeout 10*1000
  .then normalizeCoords 
  .then _.Log('current position')
  .catch returnPlaceholderCoords
