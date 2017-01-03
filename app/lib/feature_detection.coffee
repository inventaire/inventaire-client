testVideoInput = require 'lib/has_video_input'
testLocalStorage = require 'lib/local_storage'

module.exports = ->
  ISODatePolyFill()
  sayHi()
  testFlexSupport()
  testLocalStorage()
  testVideoInput()
  setDebugSetting()
  return

sayHi = ->
  console.log """

  ,___,
  [-.-]   I've been expecting you, Mr Bond
  /)__)
  -"--"-
  Want to make Inventaire better? Jump in!
  Design: https://trello.com/b/0lKcsZDj/inventaire-roadmap
  Code: https://github.com/inventaire/inventaire
  ------
  """

testFlexSupport = ->
  # detect CSS display:flex support in JavaScript
  # taken from http://stackoverflow.com/questions/14386133/are-there-any-javascript-code-polyfill-available-that-enable-flexbox-2012-cs/14389903#14389903
  detector = document.createElement 'detect'
  detector.style.display = 'flex'
  unless detector.style.display is 'flex'
    console.warn 'Flex is not supported'


# from https://developer.mozilla.org/fr/docs/Web/JavaScript/Reference/Objets_globaux/Date/toISOString
ISODatePolyFill = ->
  unless DatetoISOString?

    pad = (number)->
      if number < 10 then return '0' + number
      return number

    Date::toISOString = ->
      return @getUTCFullYear() +
        '-' + pad( @getUTCMonth() + 1 ) +
        '-' + pad( @getUTCDate() ) +
        'T' + pad( @getUTCHours() ) +
        ':' + pad( @getUTCMinutes() ) +
        ':' + pad( @getUTCSeconds() ) +
        '.' + (@getUTCMilliseconds() / 1000).toFixed(3).slice(2, 5) +
        'Z'

setDebugSetting = ->
  persistantDebug = localStorageBool.get 'debug'
  queryStringDebug = window.location.search.split('debug=true').length > 1
  hostnameDebug = window.location.hostname is 'localhost'
  if persistantDebug or queryStringDebug or hostnameDebug
    console.log 'debug enabled'
    CONFIG.debug = true
  else
    console.warn "logs are disabled.\n
    Activate logs by entering this command and reloading the page:\n
    localStorage.setItem('debug', true)\n
    Or activate logs once by adding debug=true as a query parameter"
