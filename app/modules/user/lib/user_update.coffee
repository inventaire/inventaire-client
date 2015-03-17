module.exports = (app)->
  app.reqres.setHandlers
    'user:update': (options)->
      # expects: attribute, value, selector
      {attribute, value, selector} = options

      _.types [attribute, selector], 'strings...'
      # value may have differnt types so can't be verified by _.types
      unless value? then throw new Error("invalid value: #{value}")

      app.user.set(attribute, value)
      promise = app.user.save()
      app.request 'waitForCheck',
        promise: promise
        selector: selector
      return promise
