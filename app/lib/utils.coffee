muted = require './muted_logs'

String::logIt = (label)->
  console.log "[#{label}] #{@toString()}" unless isMuted(label)
  return @toString()

isMuted = (label)->
  if label?.split?
    tag = label.split(':')?[0]
    return (muted.indexOf(tag) isnt -1)

window.location.root = window.location.protocol + '//' + window.location.host

utils =
  log: (obj, label)->
    if _.isString obj
      if label? then obj.logIt(label)
      else console.log obj unless (isMuted(obj) or isMuted(label))
    else
      unless isMuted(label)
        console.log "===== #{label} =====" if label? and not isMuted(label)
        console.log obj
        console.log "-----" if label?
    return obj

  logRed: @log

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

  setCookie: (key, value)->
    $.post '/api/cookie', {key: key, value: value}
    .then (res)-> _.log res, 'setCookie: server res on setCookie'
    .fail (err)-> console.error "setCookie: failed: #{key} - #{value}: #{err}"

  i18n: (key, args)->
    if args?

      if _.isString args
        if wd.isWikidataId args
          app.request('qLabel:update')
          return "<span class='qlabel wdP' resource='https://www.wikidata.org/entity/#{args}'>#{app.polyglot.t key}</span>"
        else throw new Error 'bad wikidata identifier'

      else if _.has args, 'entitity'
        app.request('qLabel:update')
        return "<span class='qlabel wdP' resource='https://www.wikidata.org/entity/#{args}'>#{app.polyglot.t key, args}</span>"

      else app.polyglot.t key, args

    else app.polyglot.t key

  haveAMatch: (array1, array2)->
    result = false
    array1.forEach (el)->
      if array2.indexOf(el) isnt -1
        result = true
    return result

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
    [pathname, currentQueryString] = Backbone.history.fragment.split('?')
    query = @parseQuery(currentQueryString)
    _.extend query, newParams
    app.navigate @buildPath(pathname, query)

  softEncodeURI: (str)->
    if _.typeString(str)
      str.replace(/(\s|')/g, '_').replace(/\?/g, '')

  inspect: (obj)->
    window.current ||= []
    window.current.unshift(obj)
    return obj

  isMobile: require 'lib/mobile_check'

  ping: ->
    $.get '/test'
    .fail (err)-> _.log err, 'server: unreachable. You might be offline'
    .done()

  isKnownUri: (str)->
    [prefix, id] = str.split(':')
    if prefix? and id?
      switch prefix
        when 'wd'
          if wd.isWikidataId id then return true
        when 'isbn'
          if app.lib.books.isIsbn id then return true
    return false

module.exports = _.extend utils, sharedLib('utils')