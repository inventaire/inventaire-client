module.exports =
  initialize: ->
    @ready = false
    @_updateStatus()
    setTimeout @warnOnExcessiveTime.bind(@), 8000

    app.reqres.setHandlers
      'waitForData': (cb, context, args...)->
        fn = -> cb.apply context, args
        if app.data.ready then fn()
        else app.vent.on 'data:ready', fn

      'waitForUserData': (cb, context, args...)->
        fn = -> cb.apply context, args
        if app.user?.fetched then fn()
        else app.vent.on 'user:ready', fn

      'waitForFriendsItems': (cb, context, args...)->
        fn = -> cb.apply context, args
        if Items?.friends?.fetched then fn()
        else app.vent.on 'friends:items:ready', fn

  _updateStatus: ->
    # if @missing wasnt initialized
    if not @missing?
      @missing = findMissingDataSets()
      @_listenForReadyEvents()
    else
      @missing = findMissingDataSets()
      _.log @missingEvents(), 'data:missing'
      # listeners should already be there, no need to re-add them
    @_checkIfDataReady()

  _listenForReadyEvents: ->
    @missing.forEach (el)=>
      app.vent.once(el.eventName, app.data._updateStatus, app.data)

  _checkIfDataReady: ->
    if @missing.length is 0
      @ready = true
      _.log 'data:ready'
      app.vent.trigger 'data:ready'
      return true
    else false

  warnOnExcessiveTime: ->
    unless @ready
      warn = 'data:ready didnt arrived yet! Missing events:'
      console.warn warn, @missingEvents()

  missingEvents: -> JSON.stringify _.pluck(@missing, 'eventName')

findMissingDataSets = ->
  missing = []
  data.forEach (el)->
    missing.push(el)  unless el.ready()
  return missing

data = [
  {
    eventName: 'user:ready'
    ready: -> app?.user?.fetched
  },
  {
    eventName: 'items:ready'
    ready: -> Items?.personal?.fetched
  },
  {
    eventName: 'users:ready'
    ready: -> app?.users?.fetched
  },
  {
    eventName: 'entities:ready'
    ready: -> Entities?.fetched
  }
]