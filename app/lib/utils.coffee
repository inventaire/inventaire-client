module.exports =
  logAllEvents: (obj)->
    obj.on 'all', (event)->
      console.log "[#{event}]"
      console.log arguments
      console.log '---'

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