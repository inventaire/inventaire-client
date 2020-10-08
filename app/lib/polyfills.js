export default function () {
  startsWithPolyFill()
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
