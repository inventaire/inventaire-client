Promise = require 'bluebird'
mkdirp = Promise.promisify require('mkdirp')
__ = require '../paths'
json_  = require '../json'
getWikidataArchiveOrCreate = require './get_wikidata_archive_or_create'

module.exports = (lang)->
  enFull: json_.read __.src.fullkey('en')
  enShort: json_.read __.src.shortkey('en')
  enWd: json_.read __.src.wikidata('en')
  langFull: json_.read __.src.fullkey(lang)
  langFullArchive: json_.read __.src.fullkeyArchive(lang)
  langFullTransifex: json_.read __.src.fullkeyTransifex(lang)
  langShort: json_.read __.src.shortkey(lang)
  langShortArchive: json_.read __.src.shortkeyArchive(lang)
  langShortTransifex: json_.read __.src.shortkeyTransifex(lang)
  langWd: json_.read __.src.wikidata(lang)
  langWdArchive: getWikidataArchiveOrCreate lang
