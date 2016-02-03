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

    navigator.geolocation.getCurrentPosition resolve, formattedReject,
      timeout: 20*1000

normalizeCoords = (position)->
  { latitude, longitude } = position.coords
  return { lat: latitude, lng: longitude }

PositionError = (containerId)->
  catcher = (err)->
    $("##{containerId}").addClass 'position-error'
    .html errIcon + _.i18n("couldn't obtain your position")
    throw err

module.exports = (containerId)->
  currentPosition()
  .then normalizeCoords 
  .then _.Log('current position')
  .catch PositionError(containerId)
