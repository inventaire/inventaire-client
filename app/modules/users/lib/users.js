import { images } from '#lib/urls'
import { distanceBetween } from '#map/lib/geo'
const { defaultAvatar } = images

export function serializeUser (user) {
  if (!user.picture) {
    user.picture = defaultAvatar
  }
  if (app.user.has('position') && user.position) {
    setDistance(user)
  }
  return user
}

function setDistance (user) {
  const a = app.user.getCoords()
  const b = getCoords(user)
  const distance = distanceBetween(a, b)
  user.kmDistanceFormMainUser = distance
  // Under 20km, return a ~100m precision to signal the fact that location
  // aren't precise to the meter or anything close to it
  // Above, return a ~1km precision
  const precision = distance > 20 ? 0 : 1
  user.distanceFromMainUser = Number(distance.toFixed(precision)).toLocaleString(app.user.lang)
}

function getCoords (user) {
  const latLng = user.position
  if (latLng instanceof Array) {
    const [ lat, lng ] = latLng
    return { lat, lng }
  } else if (latLng != null) {
    return latLng
  } else {
    return {}
  }
}
