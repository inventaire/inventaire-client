module.exports = (app)->
  app.reqres.setHandlers
    'user:update': (options)->
      # expects: attribute, value, selector
      {attribute, value, selector} = options

      _.types [attribute, selector], 'strings...'
      # value may have differnt types so can't be verified by _.types
      unless value? then throw new Error("invalid value: #{value}")

      previousValue = app.user.get(attribute)
      app.user.set(attribute, value)

      promise = _.preq.put app.API.user,
        attribute: attribute
        value: value

      promise
      .catch reverseUpdate.bind(null, attribute, previousValue)

      app.request 'waitForCheck',
        promise: promise
        selector: selector
      return promise


reverseUpdate = (attribute, previousValue, err)->
  if previousValue?
    _.warn previousValue, "reversing #{attribute} update"
    app.user.set(attribute, previousValue)
  else
    _.warn previousValue, "couldn't reverse update: previousValue not found"