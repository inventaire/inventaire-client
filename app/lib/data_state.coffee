module.exports =
  initialize: ->
    @ready = false
    @updateStatus()

    app.reqres.setHandlers
      'waitForData': (cb, context, args...)->
        fn = -> cb.apply context, args
        if app.data.ready then fn()
        else app.vent.on 'data:ready', fn

      'waitForUserData': (cb, context, args...)->
        fn = -> cb.apply context, args
        if app.user?.fetched then fn()
        else app.vent.on 'user:ready', fn

  updateStatus: ->
    # if @missing wasnt initialized
    if not @missing?
      @missing = findMissingDataSets()
      @listenForReadyEvents()
      @checkIfDataReady()
    else
      @missing = findMissingDataSets()
      # listeners should already be there, no need to re-add them
      @checkIfDataReady()

  listenForReadyEvents: ->
    @missing.forEach (el)=>
      app.vent.once el.eventName, app.data.updateStatus, app.data

  checkIfDataReady: ->
    if @missing.length is 0
      @ready = true
      app.vent.trigger 'data:ready'
      return true
    else false


findMissingDataSets = ->
  missing = []
  data.forEach (el)->
    if not el.control()
      missing.push el
  return missing

data = [
  {
    eventName: 'user:ready'
    control: -> app?.user?.fetched
  },
  {
    eventName: 'items:ready'
    control: -> Items?.personal?.fetched
  },
  {
    eventName: 'users:ready'
    control: -> app?.users?.fetched
  },
  {
    eventName: 'entities:ready'
    control: -> Entities?.fetched
  }
]