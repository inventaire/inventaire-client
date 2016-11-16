startTime = new Date().getTime()

module.exports = Backbone.NestedModel.extend
  initialize: ->
    @set 'navigation', []
    @set 'error', []
    @set 'time', {first: startTime}
    @logFirstLoadTime()

    # need tools thar aren't available yet
    @once 'update', @setId.bind(@)
    # dont update more than ones every seconds
    @on 'update', _.debounce(@sync, 1000)
    # update every 30 seconds
    setInterval @update.bind(@), 30 * 1000

  setId: ->
    # dev-friendly date, but shorter
    day = _.simpleDay().replace /-/g, ''
    # just keeping the part representing the day time
    # => sequential ids, while shorter than full epoch time
    millisec = _.timeSinceMidnight()
    # in case two user start a session at the same millisecond - -
    badLuckToken = _.idGenerator(4)
    @set '_id', "#{day}-#{millisec}-#{badLuckToken}"

  update: ->
    # updates both last page time and time.last
    @updateLastPageTime @timer()
    @trigger 'update'

  sync: ->
    report = @toJSON()
    # avoid to send reports without navigation or error
    # what the server would see as wrongly formatted reports
    if report.navigation?
      $.post '/api/logs/public', report

  record: (page)->
    timestamp = Date.now()
    action =
      # sometimes there is a root /, sometimes not
      # normalizing to always have one
      page: "/#{page}".replace('//', '/')
      timestamp: timestamp

    @updateLastPageTime(timestamp)
    @updateSessionTime()
    push @, 'navigation', action
    @trigger 'update'

  recordError: (error)->
    unless @dupplicatedError error
      hash = _.hashCode JSON.stringify(error)
      error.hash = hash
      push @, 'error', error
      @lastPageSet 'errorHash', hash
      @trigger 'update'

  dupplicatedError: (error)->
    msg = error.error?[0] or error.message
    sameMessage = (err)-> err.error[0] is msg
    return @get('error').filter(sameMessage).length > 0

  updateLastPageTime: (timestamp)->
    # not using Array::last as it might not be defined yet
    last = @get('navigation')?.slice(-1)[0]
    if last?
      lastIndex = @get('navigation').length - 1
      key = "navigation[#{lastIndex}].time"
      pageTime = (timestamp - last.timestamp) / 1000
      @set key, pageTime

  lastPageSet: (attr, value)->
    # not using Array::last as it might not be defined yet
    last = @get('navigation')?.slice(-1)[0]
    if last?
      lastIndex = @get('navigation').length - 1
      key = "navigation[#{lastIndex}].#{attr}"
      if key? then @set key, value
    else
      push @, 'navigation', {attr: value}

  logFirstLoadTime: ->
    window.onload = @firstLoadTime.bind(@)

  firstLoadTime: ->
    time = @timer()
    _.log time, 'first load time'
    @set 'time.firstLoadTime', time

  timer: ->
    first = @get('time.first')
    now = Date.now()
    @set 'time.last', now
    time = (now - first) / 1000
    return time

  updateSessionTime: ->
    @set 'time.sessionTimeSec', @timer()


# not using Backbone::push as Session::recordError
# might be called before Backbone::push is defined

push = (model, attribute, value)->
  arr = model.get attribute
  arr.push value
  model.set attribute, arr