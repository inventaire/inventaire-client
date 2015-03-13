module.exports = (app)->
  app.reqres.setHandlers
    'user:update': (options)->
      # expects: attribute, value, selector
      {attribute, value, selector} = options
      app.user.set(attribute, value)
      promise = app.user.save()
      app.request 'waitForCheck',
        promise: promise
        selector: selector
      return promise
