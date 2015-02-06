module.exports = ->
  sayHi()
  testFlexSupport()


sayHi = ->
  console.log """

  ,___,
  [-.-]   I've been expecting you, Mr Bond
  /)__)
  -"--"-
  Want to make Inventaire better? Jump in! https://github.com/maxlath/inventaire
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