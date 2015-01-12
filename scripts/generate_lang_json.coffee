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
fs = require 'graceful-fs'
Promise = require 'bluebird'
Promise.promisifyAll(fs)
pluckSettled = (results)-> _.pluck results, '_settledValue'
_ = require 'lodash'

__ =
  src:
    root: "./public/i18n/src"
    fullkey: (path)-> "#{@root}/fullkey/#{path}.json"
    shortkey: (path)-> "#{@root}/shortkey/#{path}.json"
    wikidata: (path)-> "#{@root}/wikidata/#{path}.json"
  dist: (path)-> "./public/i18n/dist/#{path}.json"


json_  =
  read: (path)->
    fs.readFileAsync(path)
    .then (text)-> JSON.parse text.toString()
    .catch (err)->
      if err?.cause?.errno is 34
        console.log "file not found: #{path}".yellow
        return {}
      else
        console.log "error reading file at #{path}".red, err.stack
        throw err

  write: (path, data)->
    json = JSON.stringify data, null, 4
    fs.writeFileAsync(path, json)

extendLangWithDefault = (lang)->
  Promise.settle getSources(lang)
  .then pluckSettled
  .spread (args...)->
    rethrowErrors(args)

    [
      enFull, enShort, enWd
      langFull, langShort, langWd
    ] = args

    [full, updateFull] = compareDefaultAndLang(enFull, langFull)
    [short, updateShort] = compareDefaultAndLang(enShort, langShort)
    [wd, updateWd] = compareDefaultAndLang(enWd, langWd, true)

    saveMissingValue lang, updateFull, updateShort, updateWd
    writeResult lang, _.extend({}, full, short, wd)

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
    json_.read __.src.shortkey(lang)
    json_.read __.src.wikidata(lang)
  ]

compareDefaultAndLang = (enObj, langObj, keepOldKeys)->
  # result will be the language 'dist' version
  # update will replace the previous 'src' version
  # (=> omits keys that were remove from the English version)
  # unless keepOldKeys is true
  result = {}
  if keepOldKeys then update = langObj
  else update = {}

  for k,v of enObj
    langVal = langObj[k]
    if langVal?
      result[k] = update[k] = langVal
    else
      result[k] = v
      # allows to highlight the missing translations
      # per-languages in the src files
      update[k] = null
  return [result, update]

saveMissingValue = (lang, updateFull, updateShort, updateWd)->
  Promise.all [
    json_.write(__.src.fullkey(lang), updateFull)
    json_.write(__.src.shortkey(lang), updateShort)
    json_.write(__.src.wikidata(lang), updateWd)
  ]
  .then -> console.log "#{lang} src updated!".blue
  .catch (err)-> console.log "couldnt update #{lang} src files", err.stack

count = 0
total = args.length
writeResult = (lang, result)->
  json_.write __.dist(lang), result
  .then ->
    console.log "#{lang} done! total: #{++count}".green
    if count is total then console.timeEnd 'generate'.grey

console.time 'generate'.grey
args.forEach extendLangWithDefault
