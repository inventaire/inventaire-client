__ = require '../paths'
json_  = require '../json'
{ green } = require 'chalk'

count = 0

module.exports = (lang, dist)->
  json_.write __.dist(lang), dist
  .then -> console.log green("#{lang} done! total: #{++count}")
