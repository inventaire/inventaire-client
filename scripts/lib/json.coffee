require 'colors'
fs = require 'graceful-fs'
Promise = require 'bluebird'
Promise.promisifyAll(fs)
_ = require 'lodash'

read = (path)->
  # returning a null path when a lang doesnt have an active source
  # ex: no translation on transifex
  unless path? then return Promise.resolve {}

  fs.readFileAsync path
  .catch (err)->
    if err?.cause?.errno is 34
      console.log "file not found: #{path}. Replacing by {}".yellow
    else
      console.log "error reading file at #{path}. Replacing by {}".red, err.stack
  .then (text)->
    if text? and text.length > 0 then return JSON.parse text.toString()
    else return {}
  .catch (err)-> console.log "parsing error at #{path}".red, err

write = (path, data)->
  unless path? then return Promise.resolve()

  json = JSON.stringify data, null, 4
  fs.writeFileAsync(path, json)

module.exports =
  # caching results as 'en' files will be requested multiple times
  read: _.memoize read
  write: write