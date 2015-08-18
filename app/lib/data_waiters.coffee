module.exports = ->

  # 'ready' should be function so that its value isn't blocked
  # to its value when Waiters reqres are defined
  # (i.e. necessarly false or undefined) while the first call might
  # be well after the event occured
  Waiter = (eventName, ready)->
    fn = ->
      if ready() then return _.preq.resolve()
      else
        def = Promise.defer()
        app.vent.once eventName, def.resolve.bind(def)
        return def.promise

    # always return the same promise
    return _.once fn

  waitForItems = ->
    unless app.user.loggedIn then return _.preq.resolve()

    if Items?.friends?.fetched and Items.personal?.fetched
      return _.preq.resolve()
    else
      def = Promise.defer()
      app.vent.once 'friends:items:ready', ->
        if Items.personal?.fetched then def.resolve()
      app.vent.once 'items:ready', ->
        if Items.friends?.fetched then def.resolve()
      return def.promise

  app.reqres.setHandlers
    'waitForData': Waiter 'data:ready', -> app.data.ready
    'waitForData:after': Waiter 'data:ready:after', -> app.data.ready
    'waitForUserData': Waiter 'user:ready', -> app.user?.fetched
    'waitForFriendsItems': Waiter 'friends:items:ready', -> Items?.friends?.fetched
    'waitForItems': _.once waitForItems
