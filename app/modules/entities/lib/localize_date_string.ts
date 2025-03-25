export function localizeDateString (dateString) {
  const datePrecision = precisionByDateStringLength[dateString.length] || 'year'
  dateString = fillDateString(dateString, datePrecision)
  const date = new Date(dateString.split('-'))

  // First argument is 'undefined' to let the browser
  // set the language variable.
  return date.toLocaleDateString(undefined, optionsDatesByPrecisions[datePrecision])
}

const precisionByDateStringLength = {
  4: 'year',
  7: 'month',
  10: 'day',
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
