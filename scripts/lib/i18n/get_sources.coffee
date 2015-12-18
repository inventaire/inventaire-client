Promise = require 'bluebird'
mkdirp = Promise.promisify require('mkdirp')
__ = require '../paths'
json_  = require '../json'

module.exports = (lang)->
  return [
    json_.read __.src.fullkey('en')
    json_.read __.src.shortkey('en')
    json_.read __.src.wikidata('en')
    json_.read __.src.fullkey(lang)
    json_.read __.src.fullkeyArchive(lang)
    json_.read __.src.fullkeyTransifex(lang)
    json_.read __.src.shortkey(lang)
    json_.read __.src.shortkeyArchive(lang)
    json_.read __.src.shortkeyTransifex(lang)
    json_.read __.src.wikidata(lang)
    json_.read __.src.wikidataArchive(lang)
  ]