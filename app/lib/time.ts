import { assertNumber } from '#app/lib/assert_types'
import { i18n } from '#user/lib/i18n'
import { mainUser } from '#user/lib/main_user'

const oneSecond = 1000
const oneMinute = 60 * oneSecond
const oneHour = 60 * oneMinute
const oneDay = 24 * oneHour
const oneYear = 365.25 * oneDay
const oneMonth = oneYear / 12

export function getTimeFromNowData (date: EpochTimeStamp) {
  assertNumber(date)
  const diff = Date.now() - date
  if (diff < (10 * oneSecond)) {
    return { key: 'just now', amount: 0 }
  } else if (diff < (0.9 * oneMinute)) {
    return { key: 'x_seconds_ago', amount: Math.round(diff / oneSecond) }
  } else if (diff < (0.9 * oneHour)) {
    return { key: 'x_minutes_ago', amount: Math.round(diff / oneMinute) }
  } else if (diff < (0.9 * oneDay)) {
    return { key: 'x_hours_ago', amount: Math.round(diff / oneHour) }
  } else if (diff < (0.9 * oneMonth)) {
    return { key: 'x_days_ago', amount: Math.round(diff / oneDay) }
  } else if (diff < (0.9 * oneYear)) {
    return { key: 'x_months_ago', amount: Math.round(diff / oneMonth) }
  } else {
    return { key: 'x_years_ago', amount: Math.round(diff / oneYear) }
  }
}

export function timeFromNow (date: EpochTimeStamp) {
  const { key, amount } = getTimeFromNowData(date)
  return i18n(key, { smart_count: amount })
}

export const getLocalTimeString = (date: EpochTimeStamp) => new Date(date).toLocaleString(mainUser.lang)
export const getISOTime = (date: EpochTimeStamp) => new Date(date).toISOString()

export function getISODay (date?: EpochTimeStamp) {
  const dateObj = date != null ? new Date(date) : new Date()
  return dateObj.toISOString().split('T')[0]
}

export function getSimpleTime (date?: EpochTimeStamp) {
  const dateObj = date != null ? new Date(date) : new Date()
  const [ day, time ] = dateObj.toISOString().split('T')
  return `${day} ${time.split('.')[0]}`
}

export const getNumberOfDaysAgo = (epochTime: EpochTimeStamp) => Math.floor((Date.now() - epochTime) / oneDay)

export const expired = (timestamp: EpochTimeStamp, ttl: number) => (Date.now() - timestamp) > ttl
