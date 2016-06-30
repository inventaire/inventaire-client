online = null
initDataWaiters = require './waiters'

module.exports = ->
  @ready = false
  app.data = {}
  ping()

  initDataWaiters()

  app.reqres.setHandlers
    'ifOnline': (success, showOfflineError)->
      cb = ->
        if online then success()
        else
          if showOfflineError then app.execute 'show:offline:error'
          else console.warn "can't reach the server"

      # online isnt defined before first ping returned
      if online? then cb()
      else app.vent.once 'app:online', cb()

ping = ->
  _.preq.get app.API.tests
  .then ->
    online = true
    app.vent.trigger 'app:online'
  .catch (err)->
    online = false
    console.warn 'server: unreachable. You might be offline', err
