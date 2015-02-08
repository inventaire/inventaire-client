module.exports = Backbone.NestedModel.extend
  initialize: ->
    @set 'navigation', []
    @set 'error', []
    @set 'time', {first: _.now()}
    @logFirstLoadTime()


    # dont update more than ones every seconds
    @on 'update', _.debounce(@sync, 1000)
    # update every 30 seconds
    setInterval @update.bind(@), 30 * 1000

  update: ->
    # updates both last page time and time.last
    @updateLastPageTime @timer()
    @trigger 'update'

  record: (page)->
    @lateInit()

    timestamp = _.now()
    action =
      # sometimes there is a root /, sometimes not
      # normalizing to always have one
      page: "/#{page}".replace('//', '/')
      timestamp: timestamp

    @updateLastPageTime(timestamp)
    @updateSessionTime()
    @push 'navigation', action
    @trigger 'update'

  recordError: (error)->
    hash = _.hashCode JSON.stringify(error)
    error.hash = hash
    @push 'error', error
    @lastPageSet 'errorHash', hash
    @trigger 'update'

  updateLastPageTime: (timestamp)->
    last = @get('navigation')?.slice(-1)[0]
    if last?
      lastIndex = @get('navigation').length - 1
      key = "navigation[#{lastIndex}].time"
      pageTime = (timestamp - last.timestamp) / 1000
      @set key, pageTime

  lastPageSet: (attr, value)->
    last = @get('navigation')?.slice(-1)[0]
    if last?
      lastIndex = @get('navigation').length - 1
      key = "navigation[#{lastIndex}].#{attr}"
      if key? then @set key, value

  lateInit: ->
    # can't be initialized earlier
    # due to _ being unavailable then
    unless @id?
      date = new Date().toISOString().split('T')[0]
      token = _.idGenerator(10)
      @set '_id', "#{date}-#{token}"

  logFirstLoadTime: ->
    window.onload = @firstLoadTime.bind(@)

  firstLoadTime: ->
    time = @timer()
    _.log time, 'first load time'
    @set 'time.firstLoadTime', time

  timer: ->
    first = @get('time.first')
    now = _.now()
    @set 'time.last', now
    time = (now - first) / 1000
    return time

  updateSessionTime: ->
    @set 'time.sessionTimeSec', @timer()

  sync: ->
    $.post '/api/logs/public', @toJSON()