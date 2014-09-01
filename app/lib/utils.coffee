String::label = (label)->
  console.log "[#{label}] #{@toString()}" unless isMuted(label)
  return @toString()

muted = require './muted_logs'
isMuted = (label)->
  if label?.split?
    tag = label.split(':')?[0]
    return (muted.indexOf(tag) isnt -1)

module.exports =
  log: (obj, label)->
    if typeof obj is 'string'
      if label? then obj.label(label)
      else console.log obj unless (isMuted(obj) or isMuted(label))
    else
      unless isMuted(label)
        console.log "===== #{label} =====" if label? and not isMuted(label)
        console.log obj
        console.log "-----" if label?
    return obj

  logAllEvents: (obj, prefix='logAllEvents')->
    obj.on 'all', (event)->
      console.log "[#{prefix}:#{event}]"
      console.log arguments
      console.log '---'

  logArgs: (args)->
    console.log "[arguments]"
    console.log args
    console.log '---'

  idGenerator: (length)->
    text = ""
    possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    i = 0
    while i < length
      text += possible.charAt(Math.floor(Math.random() * possible.length))
      i++
    return text

  setCookie: (key, value)->
    $.post '/api/cookie', {key: key, value: value}
    .then (res)-> _.log res, 'setCookie: server res on setCookie'
    .fail (err)-> console.error "setCookie: failed: #{key} - #{value}"

  i18n: (key, args)->
    if args?

      if typeof args is 'string'
        if /^(Q||P)[0-9]+$/.test args
          app.request('qLabel:update')
          return "<span class='qlabel wdP' resource='https://www.wikidata.org/entity/#{args}'>#{app.polyglot.t key}</span>"
        else throw new Error 'bad wikidata identifier'

      else if _.has args, 'entitity'
        app.request('qLabel:update')
        return "<span class='qlabel wdP' resource='https://www.wikidata.org/entity/#{args}'>#{app.polyglot.t key, args}</span>"

      else app.polyglot.t key, args

    else app.polyglot.t key

  # weak but handy
  hasDiff: (obj1, obj2)-> JSON.stringify(obj1) != JSON.stringify(obj2)
  hasValue: (array, value)-> array.indexOf(value) isnt -1
  haveAMatch: (array1, array2)->
    result = false
    array1.forEach (el)->
      if array2.indexOf(el) isnt -1
        result = true
    return result

  wmCommonsThumb: (file, width=100)->
    "http://commons.wikimedia.org/w/thumb.php?width=#{width}&f=#{file}"

  getCurrentRoute: ->
    route =
      rawPath: window.location.pathname + window.location.search + window.location.hash
      pathname: decodeURIComponent window.location.pathname
      search: decodeURIComponent window.location.search
      hash: decodeURIComponent window.location.hash
    route.path = route.pathname + route.search + route.hash
    route.query = @parseQuery route.search
    return route

  encodedURL: ->
    route = @getCurrentRoute
    return route.path isnt route.rawPath

  parseQuery: (queryString)->
    query = new Object
    if queryString?
      queryString = queryString[1..-1] if queryString[0] is '?'
      for i in queryString.split('&')
        pair = i.split '='
        if pair[0]?.length > 0 and pair[1]?
          query[pair[0]] = pair[1].replace('_',' ')
    return query


  updateQuery: (newParams)->
    [pathname, queryString] = Backbone.history.fragment.split('?')
    query = @parseQuery(queryString)
    _.extend query, newParams
    app.navigate @buildPath(pathname, query)

  buildPath: (pathname, queryObj)->
    if queryObj? and not _.isEmpty queryObj
      queries = ''
      for k,v of queryObj
        queries += "&#{k}=#{v}"
      return pathname + '?' + queries[1..-1]
    else pathname

  softEncodeURI: (str)->
    str.replace(' ', '_', 'g').replace "'", '_', 'g'