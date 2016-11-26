Promise = require '../bluebird'
mkdirp = Promise.promisify require('mkdirp')
__ = require '../paths'
json_  = require '../json'
getWikidataArchiveOrCreate = require './get_wikidata_archive_or_create'

module.exports = (lang)->
  enFull: json_.read __.src.fullkey('en')
  enShort: json_.read __.src.shortkey('en')
  enWd: json_.read __.src.wikidata('en')
  langFullTransifex: json_.read __.src.fullkeyTransifex(lang)
  langShortTransifex: json_.read __.src.shortkeyTransifex(lang)
  langWd: json_.read __.src.wikidata(lang)
  langWdArchive: getWikidataArchiveOrCreate lang
