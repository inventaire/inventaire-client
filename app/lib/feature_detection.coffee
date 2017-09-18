testVideoInput = require 'lib/has_video_input'
testLocalStorage = require 'lib/local_storage'
{ wiki, roadmap, git } = require 'lib/urls'

module.exports = ->
  ISODatePolyFill()
  sayHi()
  testLocalStorage()
  testVideoInput()
  setDebugSetting()
  # If flex isn't supported, invite to install a more modern browser
  return testFlexSupport()

sayHi = ->
  console.log """
  ,___,
  [-.-]   I've been expecting you, Mr Bond
  /)__)
  -"--"-
  Want to make Inventaire better? Jump in!
  Wiki: #{wiki}
  Design: #{roadmap}
  Code: #{git}/inventaire
  ------
  """

# Inspired by https://gist.github.com/davidhund/b995353fdf9ce387b8a2
# and https://stackoverflow.com/a/14389903/3324977
testFlexSupport = ->
  try
    el = document.createElement 'detect'
    # Also accept with a webkit prefix to tolerate Safari 7 and 8
    # cf http://caniuse.com/#feat=flexbox
    el.style.display = '-webkit-flex'
    el.style.display = 'flex'
    return el.style.display is 'flex' or el.style.display is '-webkit-flex'
  catch err
    return false

# from https://developer.mozilla.org/fr/docs/Web/JavaScript/Reference/Objets_globaux/Date/toISOString
ISODatePolyFill = ->
  unless Date::toISOString?

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
