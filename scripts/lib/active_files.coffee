fs = require 'graceful-fs'

module.exports = (path)->
  list = fs.readdirSync path
  return list.map (file)-> file.split('.')[0]