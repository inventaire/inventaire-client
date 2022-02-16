import assert_ from '#lib/assert_types'
const oneSecond = 1000
const oneMinute = 60 * oneSecond
const oneHour = 60 * oneMinute
const oneDay = 24 * oneHour
const oneYear = 365.25 * oneDay
const oneMonth = oneYear / 12

export default function (date) {
  assert_.number(date)
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
