#!/usr/bin/env coffee

unless /client$/.test process.cwd()
  throw new Error 'this script should be run from the /client/ folder'

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

# FRENCH INITIALIZATION
# read french fullkey
json_.read __.src.fullkey('fr')
.then (obj)->
  result = {}
  for k,v of obj
    # french key is the english value too
    result[k] = k
  return result
.then (res)->
  # write english fullkey
  json_.write __.src.fullkey('en'), res