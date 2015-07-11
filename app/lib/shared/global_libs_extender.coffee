module.exports = ->
  Array::first = -> @[0]
  Array::last = -> @slice(-1)[0]
  Array::clone = -> @slice(0)

  add = (a, b)-> a + b
  Array::sum = -> @reduce add, 0
  return