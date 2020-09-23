/* eslint-disable
    import/no-duplicates,
    no-extend-native,
    no-multi-str,
    no-return-assign,
    no-undef,
    no-var,
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
import testVideoInput from 'lib/has_video_input'
import testLocalStorage from 'lib/local_storage'
import { wiki, roadmap, git } from 'lib/urls'

export default function () {
  if (window.env === 'prod') { sayHi() }
  ISODatePolyFill()
  startsWithPolyFill()
  testFlexSupport()
  testLocalStorage()
  testVideoInput()
  setDebugSetting()
};

var sayHi = () => console.log(`\
,___,
[-.-]   I've been expecting you, Mr Bond
/)__)
-"--"-
Want to make Inventaire better? Jump in!
Wiki: ${wiki}
Design: ${roadmap}
Code: ${git}/inventaire
------\
`
)

var testFlexSupport = function () {
  // detect CSS display:flex support in JavaScript
  // taken from http://stackoverflow.com/questions/14386133/are-there-any-javascript-code-polyfill-available-that-enable-flexbox-2012-cs/14389903#14389903
  const detector = document.createElement('detect')
  detector.style.display = 'flex'
  if (detector.style.display !== 'flex') {
    return console.warn('Flex is not supported')
  }
}

// from https://developer.mozilla.org/fr/docs/Web/JavaScript/Reference/Objets_globaux/Date/toISOString
var ISODatePolyFill = function () {
  if (Date.prototype.toISOString == null) {
    const pad = function (number) {
      if (number < 10) { return '0' + number }
      return number
    }

    return Date.prototype.toISOString = function () {
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
var startsWithPolyFill = function () {
  if (String.prototype.startsWith == null) {
    return String.prototype.startsWith = function (search, pos) {
      const start = !pos || (pos < 0) ? 0 : +pos
      return this.substr(start, search.length) === search
    }
  }
}

var setDebugSetting = function () {
  const persistantDebug = localStorageBool.get('debug')
  const queryStringDebug = window.location.search.split('debug=true').length > 1
  const hostnameDebug = window.location.hostname === 'localhost'
  if (persistantDebug || queryStringDebug || hostnameDebug) {
    console.log('debug enabled')
    return CONFIG.debug = true
  } else {
    return console.warn('logs are disabled.\n \
Activate logs by entering this command and reloading the page:\n \
localStorage.setItem(\'debug\', true)\n \
Or activate logs once by adding debug=true as a query parameter'
    )
  }
}
