__ = require '../paths'
json_  = require '../json'

count = 0

module.exports = (lang, dist)->
  json_.write __.dist(lang), dist
  .then -> console.log "#{lang} done! total: #{++count}".green
