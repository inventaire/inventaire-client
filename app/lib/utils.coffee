String::label = (label)->
  console.log "[#{label}] #{@toString()}"
  return @toString()

module.exports =
  log: (obj, label)->
    if typeof obj is 'string'
      if label? then obj.label(label)
      else console.log obj
    else
      console.log "===== #{label} =====" if label?
      console.log obj
      console.log "-----" if label?
    return obj

  logAllEvents: (obj)->
    obj.on 'all', (event)->
      console.log "[#{event}]"
      console.log arguments
      console.log '---'


  logArgs: (args)->
    console.log "[arguments]"
    console.log args
    console.log '---'

  idGenerator: (length)->
    text = ""
    possible="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    i = 0
    while i < length
      text += possible.charAt(Math.floor(Math.random() * possible.length))
      i++
    return text

  setCookie: (key, value)->
    $.post '/api/cookie', {key: key, value: value}
    .then (res)-> _.log res, 'server res on setCookie'
    .fail (err)-> console.error "setCookie failed: #{key} - #{value}"

  i18n: (key, args)->
    if args?

      if typeof args is 'string'
        if /^(Q||P)[0-9]+$/.test args
          app.request('qLabel:update')
          return "<span class='qlabel wdP' resource='https://www.wikidata.org/entity/#{args}'>#{app.polyglot.t key}</span>"
        else
          throw new Error 'bad wikidata identifier'

      else if _.has args, 'entitity'
        app.request('qLabel:update')
        return "<span class='qlabel wdP' resource='https://www.wikidata.org/entity/#{args}'>#{app.polyglot.t key, args}</span>"

      else
        return app.polyglot.t key, args

    else
      return app.polyglot.t key

  hasValue: (array, value)-> array.indexOf(value) isnt -1
