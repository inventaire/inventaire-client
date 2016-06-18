require 'colors'
fs = require 'graceful-fs'
Promise = require './bluebird'
Promise.promisifyAll(fs)
_ = require 'lodash'
cwd = process.cwd()

read = (path, createIfMissing)->
  unless path? then return Promise.resolve {}

  # using the absolutePath as require would need a file relative path otherwise
  # and we don't have it
  absolutePath = cwd + path.replace(/^./, '')

  Promise.try -> require(absolutePath)

write = (path, data)->
  # skip a write operation by return null
  unless path? then return Promise.resolve()

  unless typeof path is 'string'
    return Promise.reject new Error('path isnt a string')
  unless typeof data is 'object'
    return Promise.reject new Error('data isnt a object')


  json = JSON.stringify data, null, 4
  return fs.writeFileAsync path, json

module.exports =
  read: read
  write: write
