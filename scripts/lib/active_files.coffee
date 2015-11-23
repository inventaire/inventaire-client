fs = require 'graceful-fs'
identity = (a)-> a

module.exports = (path, filter)->
  filter or= identity

  fs.readdirSync path
  .filter filter
  .map (file)-> file.split('.')[0]
