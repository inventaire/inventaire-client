module.exports =
  log: (obj, label)->
    if typeof obj is 'string'
      if label?
        console.log "[#{label}]: #{obj}"
      else
        console.log obj
    else
      console.log "----- #{label} -----" if label?
      console.log obj
      console.log "-----" if label?

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