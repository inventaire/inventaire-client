fs = require 'fs'
Promise = require 'bluebird'
writeFile = Promise.promisify fs.writeFile

module.exports = (path, content)->
  console.log 'writting sitemap'.grey, path
  writeFile path, content, (err, res)->
    if err? then console.log 'err'.red, err
    else console.log 'done!'.green