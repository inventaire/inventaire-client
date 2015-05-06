module.exports = ->

  Waiter = (ready, eventName)->
    fn = ->
      if ready then _.preq.resolve()
      else
        def = Promise.defer()
        app.vent.once eventName, def.resolve.bind(def)
        return def.promise

    # always return the same promise
    return _.once fn

  waitForItems = ->
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
    'waitForData': Waiter app.data.ready, 'data:ready'
    'waitForData:after': Waiter app.data.ready, 'data:ready:after'
    'waitForUserData': Waiter app.user?.fetched, 'user:ready'
    'waitForFriendsItems': Waiter Items?.friends?.fetched, 'friends:items:ready'
    'waitForItems': _.once waitForItems
