module.exports = (app)->
  app.reqres.setHandlers
    'user:update': (options)->
      # required: attribute, value
      # optional: selector, defaultPreviousValue
      { attribute, value, selector, defaultPreviousValue } = options

      # _.types [attribute, selector], 'strings...'
      # # value may have differnt types so can't be verified by _.types
      # unless value? then throw new Error("invalid value: #{value}")

      previousValue = app.user.get(attribute) or defaultPreviousValue

      if value is previousValue
        _.log 'user is already up-to-date'
        promise = _.preq.resolve()
      else
        app.user.set attribute, value

        promise = _.preq.put app.API.user,
          attribute: attribute
          value: value
        .catch reverseUpdate.bind(null, attribute, previousValue)

      if selector?
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

  throw err
