module.exports =
  log: (obj, label)->
    if typeof obj is 'string'
      if label?
        console.log "[#{label}]: #{obj}"
      else
        console.log obj
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

  i18n: (key)-> app.polyglot.t key

  hasValue: (array, value)-> array.indexOf(value) isnt -1