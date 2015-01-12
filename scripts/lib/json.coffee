require 'colors'
fs = require 'graceful-fs'
Promise = require 'bluebird'
Promise.promisifyAll(fs)

module.exports =
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