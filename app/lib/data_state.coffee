module.exports =
  initialize: ->
    @ready = false
    @updateStatus()

    app.reqres.setHandlers
      'waitForData': (cb, context, args...)->
        fn = -> cb.apply context, args
        if app.data.ready then fn()
        else app.vent.on 'data:ready', fn

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
      eventName = "#{el.name}:ready"
      app.vent.once eventName, app.data.updateStatus, app.data

  checkIfDataReady: ->
    if @missing.length is 0
      @ready = true
      app.vent.trigger 'data:ready'
      return true
    else false


findMissingDataSets = ->
  missing = []
  data.forEach (el)->
    if not el.controlObject()
      missing.push el
  return missing

data = [
  {
    name: 'items'
    controlObject: -> Items.personal.fetched
  },
  {
    name: 'contacts'
    controlObject: -> app.contacts.fetched
  }
]