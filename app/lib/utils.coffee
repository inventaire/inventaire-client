muted = require './muted_logs'

String::logIt = (label)->
  console.log "[#{label}] #{@toString()}" unless isMuted(label)
  return @toString()

isMuted = (label)->
  if label?.split?
    tag = label.split(':')?[0]
    return (muted.indexOf(tag) isnt -1)

module.exports =
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

  logXhrErr: (err, label)->
    switch err.status
      when 404 then console.warn err.responseText, label
      else console.error err.responseText, err, label

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

  haveAMatch: (array1, array2)->
    result = false
    array1.forEach (el)->
      if array2.indexOf(el) isnt -1
        result = true
    return result

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

  ping: ->
    $.get '/test'
    .fail (err)-> _.log err, 'server: unreachable. You might be offline'
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
  isContact: (id)-> _.has app.user.get('contacts'), id