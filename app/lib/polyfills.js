export default async function () {
  ISODatePolyFill()
  DateNowPolyFill()
  startsWithPolyFill()

  if (!window.Promise) {
    window.Promise = await import('promise-polyfill')
  }
}

// from https://developer.mozilla.org/fr/docs/Web/JavaScript/Reference/Objets_globaux/Date/toISOString
const ISODatePolyFill = function () {
  if (Date.prototype.toISOString == null) {
    const pad = function (number) {
      if (number < 10) return '0' + number
      return number
    }

    // eslint-disable-next-line no-extend-native
    Date.prototype.toISOString = function () {
      return this.getUTCFullYear() +
        '-' + pad(this.getUTCMonth() + 1) +
        '-' + pad(this.getUTCDate()) +
        'T' + pad(this.getUTCHours()) +
        ':' + pad(this.getUTCMinutes()) +
        ':' + pad(this.getUTCSeconds()) +
        '.' + (this.getUTCMilliseconds() / 1000).toFixed(3).slice(2, 5) +
        'Z'
    }
  }
}

// Source: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/startsWith#Polyfill
const startsWithPolyFill = function () {
  if (String.prototype.startsWith == null) {
    // eslint-disable-next-line no-extend-native
    String.prototype.startsWith = function (search, pos) {
      const start = !pos || (pos < 0) ? 0 : +pos
      return this.substr(start, search.length) === search
    }
  }
}

const DateNowPolyFill = function () {
  if (Date.now == null) Date.now = () => new Date().getTime()
}
