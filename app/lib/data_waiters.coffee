module.exports = ->

  # 'ready' should be function so that its value isn't blocked
  # to its value when Waiters reqres are defined
  # (i.e. necessarly false or undefined) while the first call might
  # be well after the event occured
  Waiter = (eventName, ready)->
    _.time eventName
    fn = ->
      if ready() then return _.preq.resolved
      else
        return new Promise (resolve, reject)->
          app.vent.once eventName, ->
            _.timeEnd eventName
            resolve()

    # always return the same promise
    return _.once fn

  waitForItems = ->
    unless app.user.loggedIn then return _.preq.resolved

    if app.items?.friends?.fetched and app.items.personal?.fetched
      return _.preq.resolved
    else
      return new Promise (resolve, reject)->
        app.vent.once 'friends:items:ready', ->
          if app.items.personal?.fetched then resolve()
        app.vent.once 'items:ready', ->
          if app.items.friends?.fetched then resolve()

  app.reqres.setHandlers
    'waitForData': Waiter 'data:ready', -> app.data.ready
    'waitForData:after': Waiter 'data:ready:after', -> app.data.ready
    'waitForUserData': Waiter 'main:user:ready', -> app.user?.fetched
    'waitForFriendsItems': Waiter 'friends:items:ready', -> app.items?.friends?.fetched
    'waitForItems': _.once waitForItems
    'waitForLayout': Waiter 'layout:ready', -> app.layout?.ready
    'waitForI18n': Waiter 'i18n:ready', -> app.data.i18nReady
