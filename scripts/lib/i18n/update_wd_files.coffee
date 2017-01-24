_ = require 'lodash'
__ = require '../paths'
json_  = require '../json'
{ blue } = require 'chalk'

module.exports = (lang, updateWd, archiveWd)->
  wikidataPath = __.src.wikidata lang
  wikidataArchivePath = __.src.wikidataArchive lang
  # Filter out non-active langs
  unless wikidataPath? then return Promise.resolve()

  return Promise.all [
    json_.write wikidataPath, sortByKeys(updateWd)
    json_.write wikidataArchivePath, sortByKeys(archiveWd)
  ]
  .then -> console.log blue("update #{lang} wd src and archive")


sortByKeys = (obj)->
  keys = Object.keys(obj).map (pid)-> parseInt(pid.slice(1))
  sortedKeys = _.sortBy keys

  getPair = (key)->
    pid = 'P' + key
    return [ pid, obj[pid] ]

  return _.fromPairs _.map(sortedKeys, getPair)
