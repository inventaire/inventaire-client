Promise = require '../bluebird'
__ = require '../paths'
json_  = require '../json'
exec = Promise.promisify require('child_process').exec
wdCliCmd = './node_modules/.bin/wd'
activeLangs = require('./langs').active
{ red, blue, green } = require 'chalk'

module.exports = (lang)->
  path = __.src.wikidataArchive lang
  if path then return json_.read path

  # fetch Wikidata properties only for active languages
  # to limit to number of requests at a time
  unless lang in activeLangs
    return null

  # forcing to get a path despite the file not being there yet
  path = __.src.wikidataArchive lang, true
  console.log blue("missing Wikidata properties for #{lang}: fetching")
  exec "#{wdCliCmd} props -l #{lang} > #{path}"
  .then ->
    console.log green("#{lang} Wikidata properties fetched!: saved at #{path}")
    return json_.read path
  .catch (err)->
    console.error red('langWdArchive err'), err
    throw err
