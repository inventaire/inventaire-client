#!/usr/bin/env coffee

unless /client$/.test process.cwd()
  throw new Error 'this script should be run from the /client/ folder'

validLangs = require './valid_langs'
args = process.argv.slice(2)

checkLang = (lang)->
  unless lang in validLangs
    throw new Error "#{lang} isnt a valid lang argument"

if args.length > 0
  if args[0] is 'all' then args = validLangs
  else args.forEach checkLang
else throw new Error "expected at least one 2-letter language code as argument, got 0"

require 'colors'
Promise = require 'bluebird'
pluckSettled = (results)-> _.pluck results, '_settledValue'
_ = require 'lodash'

__ = require './lib/paths'
json_  = require './lib/json'

extendLangWithDefault = (lang)->
  Promise.settle getSources(lang)
  .then pluckSettled
  .spread (args...)->
    rethrowErrors(args)

    [
      enFull, enShort, enWd
      langFull, langFullArchive
      langShort, langShortArchive
      langWd, langWdArchive
    ] = args

    fullArgs = [enFull, langFull, langFullArchive, false]
    shortArgs = [enShort, langShort, langShortArchive, true]
    wdArgs = [enWd, langWd, langWdArchive, false]

    [full, updateFull, archiveFull] = findKeys.apply null, fullArgs
    [short, updateShort, archiveShort] = findKeys.apply null, shortArgs
    [wd, updateWd, archiveWd] = findKeys.apply null, wdArgs

    updateAndArchive lang, updateFull, archiveFull, updateShort, archiveShort, updateWd, archiveWd
    writeDistVersion lang, _.extend({}, full, short, wd)

  .catch (err)-> console.error "#{lang} err".red, err

rethrowErrors = (args)->
  args.forEach (arg)->
    if arg instanceof Error then throw arg

getSources = (lang)->
  return [
    json_.read __.src.fullkey('en')
    json_.read __.src.shortkey('en')
    json_.read __.src.wikidata('en')
    json_.read __.src.fullkey(lang)
    json_.read __.src.fullkeyArchive(lang)
    json_.read __.src.shortkey(lang)
    json_.read __.src.shortkeyArchive(lang)
    json_.read __.src.wikidata(lang)
    json_.read __.src.wikidataArchive(lang)
  ]

convertMarkdown = require './lib/convert_markdown'

findKeys = (enObj, langCurrent, langArchive, markdown)->
  # dist will be the language 'dist' version
  # update will replace the previous 'src' version
  # archive will keep keys that werent in the English version)
  langObj = _.extend {}, langCurrent, langArchive
  dist = {}
  update = {}

  for k,enVal of enObj
    langVal = langObj[k]
    if langVal?
      dist[k] = update[k] = langVal
    else
      dist[k] = enVal
      # allows to highlight the missing translations
      # per-languages in the src files
      update[k] = null
    if markdown
      dist[k] = convertMarkdown dist[k]

    archive = _.omit langObj, Object.keys(update)
    # console.log 'archive'.blue, archive

  return [dist, update, archive]

updateAndArchive = (lang, updateFull, archiveFull, updateShort, archiveShort, updateWd, archiveWd)->
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

count = 0
total = args.length
writeDistVersion = (lang, dist)->
  json_.write __.dist(lang), dist
  .then ->
    console.log "#{lang} done! total: #{++count}".green
    if count is total then console.timeEnd 'generate'.grey

mkdirp = Promise.promisify require('mkdirp')

createDirs =  [
    mkdirp __.distRoot
    mkdirp __.src.fk('archive')
    mkdirp __.src.sk('archive')
    mkdirp __.src.wd('archive')
  ]

console.time 'generate'.grey
Promise.all createDirs
.then ->
  console.log 'directories initialized'.green
  args.forEach extendLangWithDefault
.catch (err)-> console.log 'global err'.red, err
