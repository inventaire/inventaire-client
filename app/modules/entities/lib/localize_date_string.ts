import app from '#app/app'

export function localizeDateString (dateString) {
  const datePartsCount = dateString.replace(/^-/, '').split('-').length
  const datePrecision = precisionByDatePartsCount[datePartsCount] || 'year'
  dateString = fillDateString(dateString, datePrecision)
  const date = new Date(dateString)

  const preferredLocal = navigator.languages?.find(local => local.startsWith(`${app.user.lang}-`)) || undefined
  return date.toLocaleDateString(preferredLocal, optionsDatesByPrecisions[datePrecision])
}

const precisionByDatePartsCount = {
  1: 'year',
  2: 'month',
  3: 'day',
}

function fillDateString (dateString, datePrecision) {
  // The Date Object needs a defined day, even if a month precision will be displayed.
  // This adds a day placeholder when necessary
  return datePrecision === 'month' ? `${dateString}-01` : dateString
}

const optionsDatesByPrecisions = {
  year: {
    year: 'numeric',
  },
  month: {
    year: 'numeric',
    month: 'long',
  },
  day: {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  },
}
