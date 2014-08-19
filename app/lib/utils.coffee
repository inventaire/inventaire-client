String::label = (label)->
  console.log "[#{label}] #{@toString()}" unless isMuted(label)
  return @toString()

muted = require 'lib/muted_logs'
isMuted = (label)->
  if label?
    tag = label.split(':')?[0]
    return (muted.indexOf(tag) isnt -1)
  else false

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

  hasValue: (array, value)-> array.indexOf(value) isnt -1

  wmCommonsThumb: (file, width=100)->
    "http://commons.wikimedia.org/w/thumb.php?width=#{width}&f=#{file}"

  getCurrentRoute: ->
    route =
      rawPath: window.location.pathname + window.location.search + window.location.hash
      pathname: decodeURIComponent window.location.pathname
      search: decodeURIComponent window.location.search
      hash: decodeURIComponent window.location.hash
    route.path = route.pathname + route.search + route.hash
    query = route.search[1..-1]
    for i in query.split('&')
      pair = i.split '='
      route.query ||= new Object
      route.query[pair[0]] = pair[1] if pair[0]?.length > 0
    return route

  encodedURL: ->
    route = @getCurrentRoute
    return route.path isnt route.rawPath