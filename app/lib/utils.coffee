muted = require './muted_logs'

String::logIt = (label)->
  console.log "[#{label}] #{@toString()}" unless isMuted(label)
  return @toString()

isMuted = (label)->
  if label?.split?
    tag = label.split(':')?[0]
    return (muted.indexOf(tag) isnt -1)

module.exports = (Backbone, _, app, window)->
  log: (obj, label, stack)->
    # customizing console.log
    # unfortunatly, it makes the console loose the trace
    # of the real line and file the _.log function was called from
    # the trade-off might not be worthing it...
    if _.isString obj
      if label? then obj.logIt(label)
      else console.log obj unless (isMuted(obj) or isMuted(label))
    else
      unless isMuted(label)
        console.log "===== #{label} =====" if label? and not isMuted(label)
        console.log obj
        console.log "-----" if label?

    # log a stack trace if stack option is true
    if stack
      console.log new Error('fake error').stack.split("\n")

    return obj

  error: console.error.bind(console)

  logAllEvents: (obj, prefix='logAllEvents')->
    obj.on 'all', (event)->
      console.log "[#{prefix}:#{event}]"
      console.log arguments
      console.log '---'

  logArgs: (args)->
    console.log "[arguments]"
    console.log args
    console.log '---'

  logServer: (obj, label)->
    log = {obj: obj, label: label}
    $.post('/test', log)

  logXhrErr: (err, label)->
    if err?.status?
      switch err.status
        when 404 then console.warn err.responseText, label
        else console.error err.responseText, err, label
    else console.error label, err

  setCookie: (key, value)->
    $.post '/api/cookie', {key: key, value: value}
    .then (res)-> _.log res, 'setCookie: server res on setCookie'
    .fail (err)-> console.error "setCookie: failed: #{key} - #{value}: #{err}"

  i18n: (key, args, context)->
    if args?
      if _.isString args
        if wd.isWikidataId args
          app.request('qLabel:update')
          return "<span class='qlabel wdP' resource='https://www.wikidata.org/entity/#{args}'>#{app.polyglot.t key}</span>"
        else
          obj = {}
          obj[args] = context
          return app.polyglot.t key, obj

      else if _.has args, 'entitity'
        app.request('qLabel:update')
        return "<span class='qlabel wdP' resource='https://www.wikidata.org/entity/#{args}'>#{app.polyglot.t key, args}</span>"

      else app.polyglot.t key, args

    else app.polyglot.t key

  updateQuery: (newParams)->
    [pathname, currentQueryString] = Backbone.history.fragment.split('?')
    query = @parseQuery(currentQueryString)
    _.extend query, newParams
    app.navigate @buildPath(pathname, query)

  inspect: (obj, label)->
    if label then _.log obj, label
    if window.current?
      window.previous ||= []
      window.previous.unshift(window.current)
    return window.current = obj

  ping: ->
    $.get '/test'
    .fail (err)-> console.warn 'server: unreachable. You might be offline', err
    .done()

  hasKnownUriDomain: (str)->
    if _.isString(str)
      [prefix, id] = str.split(':')
      if prefix? and id?
        switch prefix
          when 'wd'
            if wd.isWikidataId id then return true
          when 'isbn'
            if app.lib.books.isIsbn id then return true
    return false

  lastRouteMatch: (regex)->
    if Backbone.history.last?[0]?
      last = Backbone.history.last[0]
      return regex.test(last)
    else false

  placeholder: (height=250, width=200)->
    text = _.i18n 'missing image'
    "http://placehold.it/#{width}x#{height}/ddd/fff&text=#{text}"

  openJsonWindow: (obj, windowName)->
    json = JSON.stringify obj, null, 4
    data = 'data:application/json;charset=utf-8,' + encodeURI(json)
    window.open data, windowName

  isUser: (id)-> id is app.user.id
  isFriend: (id)-> @hasValue app.user.get('relations').friends, id

  style: (text, style)->
    switch style
      when 'strong' then "<strong>#{text}</strong>"

  stringOnly: (str)->
    if typeof str is 'string' then str
    else return

  isntEmpty: (array)-> not @isEmpty(array)
  proxy: (route)-> '/proxy/' + route
  pickOne: (obj)->
    k = Object.keys(obj)[0]
    return obj[k]

  isFirefox: -> window.navigator?.mozApps?

  currentLocationMatch: (str)->
    pattern = new RegExp(str)
    return pattern.test window.location.pathname

  isModel: (obj)-> obj instanceof Backbone.Model

  validImageSrc: (url, callback)->
    image = new Image()
    image.src = url
    def = $.Deferred()
    cb = ->
      if image.complete then def.resolve(url)
      else def.reject(url)
    setTimeout cb, 500

  allValid: (array, test)->
    result = true
    array.forEach (el)-> if not test(el) then result = false
    return result

  isUri: (str)->
    [prefix, id] = str.split ':'
    if prefix? and id?
      switch prefix
        when 'wd' then return wd.isWikidataId(id)
        when 'isbn' then return app.lib.books.isNormalizedIsbn(id)
    return false

  uniq: (array)->
    obj = {}
    array.forEach (value)-> obj[value] = true
    return Object.keys(obj)

  # adapted from lodash implementation
  values: (obj) ->
    index = -1
    props = Object.keys(obj)
    length = props.length
    result = Array(length)
    result[index] = obj[props[index]]  while ++index < length
    return result

  localUrl: (url)-> /^\//.test(url)