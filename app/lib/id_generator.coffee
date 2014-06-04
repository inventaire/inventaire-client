module.exports = (length)->
    text = ""
    possible="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    i = 0
    while i < length
      text += possible.charAt(Math.floor(Math.random() * possible.length))
      i++
    console.log "new id: " + text
    return text