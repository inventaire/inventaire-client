module.exports = ->
  ISODatePolyFill()
  sayHi()
  testFlexSupport()
  testLocalStorage()
  return testIndexedDbSupport()


sayHi = ->
  console.log """

  ,___,
  [-.-]   I've been expecting you, Mr Bond
  /)__)
  -"--"-
  Want to make Inventaire better? Jump in! https://github.com/inventaire/inventaire
  Guidelines and inspiration: https://inventaire.io/guidelines-and-inspiration
  ------
  """


testFlexSupport = ->
  # detect CSS display:flex support in JavaScript
  # taken from http://stackoverflow.com/questions/14386133/are-there-any-javascript-code-polyfill-available-that-enable-flexbox-2012-cs/14389903#14389903
  detector = document.createElement 'detect'
  detector.style.display = 'flex'
  if detector.style.display is 'flex' then console.log 'Flex is supported'
  else console.log 'Flex is not supported'


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
        'Z';


testLocalStorage = ->
  # if localStorage isnt supported (or more probably, blocked), replace it by a global object:
  # data won't be persisted from one session to the other, but who's fault is that
  try
    window.localStorage.setItem 'localStorage-support', true
    localStorageProxy = localStorage
    console.log 'localStorage is supported'
  catch err
    console.warn 'localStorage isnt supported'
    storage = {}
    localStorageProxy =
      getItem: (key)-> storage[key] or null
      setItem: (key, value)->
        storage[key] = value
        return
      clear: -> storage = {}

  window.localStorageProxy = localStorageProxy

testIndexedDbSupport = ->
  indexedDB = indexedDB or window.indexedDB or window.webkitIndexedDB or window.mozIndexedDB or window.OIndexedDB or window.msIndexedDB

  return solveIdbSupport(indexedDB)
  .then (bool)->
    window.supportsIndexedDB = bool
    console.log 'Indexeddb support:', bool
  .catch (err)-> console.error 'testIndexedDbSupport err', err


solveIdbSupport = (indexedDB)->
  # resolve once supportsIndexedDB is settled
  return new Promise (resolve, reject)->
    test = indexedDB.open '_indexeddb_support_detection', 1
    test.onsuccess = ->
      resolve true

    test.onerror = ->
      window.supportsIndexedDB = false
      resolve false

    return