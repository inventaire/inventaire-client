module.exports = ->
  testFlexSupport()


testFlexSupport = ->
  # detect CSS display:flex support in JavaScript
  # taken from http://stackoverflow.com/questions/14386133/are-there-any-javascript-code-polyfill-available-that-enable-flexbox-2012-cs/14389903#14389903
  detector = document.createElement 'detect'
  detector.style.display = 'flex'
  if detector.style.display is 'flex' then console.log 'Flex is supported'
  else console.log 'Flex is not supported'