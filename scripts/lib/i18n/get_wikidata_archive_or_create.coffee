Promise = require '../bluebird'
__ = require '../paths'
json_  = require '../json'
exec = Promise.promisify require('child_process').exec
wdpropsCmd = './node_modules/.bin/wdprops'
activeLangs = require('./langs').active

module.exports = (lang)->
  path = __.src.wikidataArchive lang
  if path then return json_.read path

  # fetch Wikidata properties only for active languages
  # to limit to number of requests at a time
  unless lang in activeLangs
    return null

  # forcing to get a path despite the file not being there yet
  path = __.src.wikidataArchive lang, true
  console.log "missing Wikidata properties for #{lang}: fetching".blue
  exec "#{wdpropsCmd} #{lang} > #{path}"
  .then ->
    console.log "#{lang} Wikidata properties fetched!: saved at #{path}".green
    return json_.read path
  .catch (err)->
    console.error 'langWdArchive err', err
    throw err
