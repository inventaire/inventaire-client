#!/usr/bin/env coffee

# HOW TO
# From time to time, you can replace src/fullkey/en by {}
# and browse all the website to regenerate an updated list of the fullkeys

unless /client$/.test process.cwd()
  throw new Error 'this script should be run from the /client/ folder'

validLangs = require './valid_langs'
args = process.argv.slice(2)

checkLang = (lang)->
  unless lang in validLangs
    throw new Error "#{lang} isnt a valid lang argument"

unless args.length > 0
  throw new Error "expected at least one 2-letter language code as argument, got 0"

if args[0] is 'all' then args = validLangs
else
  for arg in args
    checkLang arg

require 'colors'
Promise = require 'bluebird'
_ = require 'lodash'

__ = require './lib/paths'
json_  = require './lib/json'

extendLangWithDefault = (lang)->
  Promise.all getSources(lang)
  .then (args)->
    rethrowErrors(args)

    [
      enFull, enShort, enWd
      langFull, langFullArchive, langFullTransifex
      langShort, langShortArchive, langShortTransifex
      langWd, langWdArchive
    ] = args

    fullArgs = [enFull, langFull, langFullArchive, langFullTransifex, false]
    shortArgs = [enShort, langShort, langShortArchive, langShortTransifex, true]
    wdArgs = [enWd, langWd, langWdArchive, null, false]

    [full, updateFull, archiveFull] = findKeys.apply null, fullArgs
    [short, updateShort, archiveShort] = findKeys.apply null, shortArgs
    [wd, updateWd, archiveWd] = findKeys.apply null, wdArgs

    updateAndArchive lang, updateFull, archiveFull, updateShort, archiveShort, updateWd, archiveWd
    writeDistVersion lang, _.extend({}, full, short, wd)

  .catch (err)-> console.error "#{lang} err".red, err.stack

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
    json_.read __.src.fullkeyTransifex(lang)
    json_.read __.src.shortkey(lang)
    json_.read __.src.shortkeyArchive(lang)
    json_.read __.src.shortkeyTransifex(lang)
    json_.read __.src.wikidata(lang)
    json_.read __.src.wikidataArchive(lang)
  ]

linkify = require '../app/lib/handlebars_helpers/linkify'
convertMarkdown = require('./lib/convert_markdown')(linkify)

findKeys = (enObj, langCurrent, langArchive, langTransifex, markdown)->
  # dist will be the language 'dist' version
  # update will replace the previous 'src' version
  # archive will keep keys that werent in the English version)
  langObj = _.extend {}, langArchive

  if langTransifex?
    langTransifex = keepNonNullValues langTransifex
    invertedEnObj = _.invert enObj
    formattedLangTransifex = {}
    for k,v of langTransifex
      realKey = invertedEnObj[k]
      # transifex uses the English version as value
      # while we want it to stay 'null' to highligh that the value is missing
      if realKey? and v isnt enObj[realKey]
        formattedLangTransifex[realKey] = v

    _.extend langObj, formattedLangTransifex

  _.extend langObj, keepNonNullValues(langCurrent)

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
    # pick keys with non-null value
    cleanArchive = _.pick archive, _.identity

  return [dist, update, cleanArchive]

keepNonNullValues = (obj)-> _.pick obj, (str)-> str?

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
