import { getCurrentLang } from '#modules/user/lib/i18n'

export function localizeDateString (dateString) {
  const datePartsCount = dateString.replace(/^-/, '').split('-').length
  const datePrecision = precisionByDatePartsCount[datePartsCount] || 'year'
  dateString = fillDateString(dateString, datePrecision)
  const date = new Date(dateString)
  const userLang = getCurrentLang()
  const preferredLocale = navigator.languages?.find(locale => locale.startsWith(`${userLang}-`)) || userLang
  // undefined is letting the browser define its own locale
  const resolvableLocale = isResolvableIntlLangageCode(preferredLocale) ? preferredLocale : undefined
  return date.toLocaleDateString(resolvableLocale, optionsDatesByPrecisions[datePrecision])
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

function isResolvableIntlLangageCode (lang: string) {
  try {
    return new Intl.DateTimeFormat(lang)
  } catch (err) {
    if (err.name !== 'RangeError') throw err
    return false
  }
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
