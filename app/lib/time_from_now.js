oneSecond = 1000
oneMinute = 60 * oneSecond
oneHour = 60 * oneMinute
oneDay = 24 * oneHour
oneYear = 365.25 * oneDay
oneMonth = oneYear / 12

module.exports = (date)->
  _.type date, 'number'
  diff = Date.now() - date
  if diff < 10 * oneSecond
    return { key: 'just now', amount: 0 }
  else if diff < 0.9 * oneMinute
    return { key: 'x_seconds_ago', amount: Math.round(diff / oneSecond) }
  else if diff < 0.9 * oneHour
    return { key: 'x_minutes_ago', amount: Math.round(diff / oneMinute) }
  else if diff < 0.9 * oneDay
    return { key: 'x_hours_ago', amount: Math.round(diff / oneHour) }
  else if diff < 0.9 * oneMonth
    return { key: 'x_days_ago', amount: Math.round(diff / oneDay) }
  else if diff < 0.9 * oneYear
    return { key: 'x_months_ago', amount: Math.round(diff / oneMonth) }
  else
    return { key: 'x_years_ago', amount: Math.round(diff / oneYear) }
