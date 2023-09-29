import { truncateDecimals } from './geo.js'
import pTimeout from 'p-timeout'

// Give a good 30s, as it can sometimes take some time and actually return a result
const timeout = 30 * 1000

// doc: https://developer.mozilla.org/en-US/docs/Web/API/Geolocation/getCurrentPosition
const currentPosition = () => new Promise((resolve, reject) => {
  if (navigator.geolocation?.getCurrentPosition == null) {
    const err = new Error('getCurrentPosition isnt accessible')
    return reject(err)
  }

  // getCurrentPosition throws PositionError s that aren't instanceof Error
  // thus the need to create a new error from it
  const formattedReject = err => reject(new Error(err.message || 'getCurrentPosition error'))

  navigator.geolocation.getCurrentPosition(resolve, formattedReject, {
    timeout,
    maximumAge: 5 * 60 * 1000,
    enableHighAccuracy: false
  })
})

export async function getPositionFromNavigator () {
  const position = await pTimeout(currentPosition(), timeout + 100)
  const { latitude, longitude } = position.coords
  return { lat: truncateDecimals(latitude), lng: truncateDecimals(longitude) }
}
