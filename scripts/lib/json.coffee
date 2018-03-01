fs = require 'graceful-fs'
Promise = require './bluebird'
Promise.promisifyAll(fs)
_ = require 'lodash'
cwd = process.cwd()
{ yellow } = require 'chalk'

read = (path, createIfMissing = true)->
  unless path? then return Promise.resolve {}

  # using the absolutePath as require would need a file relative path otherwise
  # and we don't have it
  absolutePath = if path[0] is '/' then path else cwd + path.replace(/^./, '')

  # Not using require as it caches the files
  # while ./get_wikidata_archive_or_create might have refreshed them
  fs.readFileAsync absolutePath, { encoding: 'utf-8' }
  .then (file)-> JSON.parse file
  .catch (err)->
    if err.code is 'ENOENT' and createIfMissing
      console.log yellow("file not found: #{path}. Creating: {}")
      fs.writeFileAsync path, '{}'
      .then -> return {}
    else
      throw err

write = (path, data)->
  # skip a write operation by return null
  unless path? then return Promise.resolve()

  unless typeof path is 'string'
    return Promise.reject new Error('path isnt a string')
  unless typeof data is 'object'
    return Promise.reject new Error('data isnt a object')

  json = JSON.stringify data, null, 4
  return fs.writeFileAsync path, json

module.exports = { read, write }
