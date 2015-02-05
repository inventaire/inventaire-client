require 'colors'
fs = require 'graceful-fs'
Promise = require 'bluebird'
Promise.promisifyAll(fs)

module.exports =
  read: (path)->
    fs.readFileAsync(path)
    .catch (err)->
      if err?.cause?.errno is 34
        console.log "file not found: #{path}. Replacing by {}".yellow
      else
        console.log "error reading file at #{path}. Replacing by {}".red, err.stack
    .then (text)->
      if text? and text.length > 0 then return JSON.parse text.toString()
      else return {}
    .catch (err)-> console.log "parsing error at #{path}".red, err

  write: (path, data)->
    json = JSON.stringify data, null, 4
    fs.writeFileAsync(path, json)