module.exports =
  initialize: ->
    Array::first = -> @[0]
    Array::last = -> @slice(-1)[0]
    Array::clone = -> @slice(0)
    return