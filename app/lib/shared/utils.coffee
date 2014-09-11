Array::clone = -> @slice(0)


module.exports =
  hasValue: (array, value)-> array.indexOf(value) isnt -1
  yes: (one)-> console.log(one)