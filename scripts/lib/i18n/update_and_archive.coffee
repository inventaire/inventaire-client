Promise = require 'bluebird'
__ = require '../paths'
json_  = require '../json'

module.exports =  (lang, updateFull, archiveFull, updateShort, archiveShort, updateWd, archiveWd)->
  Promise.all [
    json_.write(__.src.fullkey(lang), updateFull)
    json_.write(__.src.fullkeyArchive(lang), archiveFull)
    json_.write(__.src.shortkey(lang), updateShort)
    json_.write(__.src.shortkeyArchive(lang), archiveShort)
    json_.write(__.src.wikidata(lang), updateWd)
    json_.write(__.src.wikidataArchive(lang), archiveWd)
  ]
  .then -> console.log "#{lang} src updated!".blue
  .catch (err)-> console.log "couldnt update #{lang} src files", err.stack