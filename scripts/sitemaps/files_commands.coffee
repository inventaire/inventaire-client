{ folder } = require './config'
{ exec } = require 'child_process'

fs = require 'fs'
ls = (dir)-> console.log fs.readdirSync(dir)
cp = (orignal, copy)->
  fs.createReadStream orignal
  .pipe fs.createWriteStream(copy)

{ stderr } = process

module.exports =
  rmFiles: ->
    exec("rm #{folder}/*").stderr.pipe stderr
    console.log 'removed old files'.grey
  gzipFiles: ->
    exec("for f in #{folder}/*; do gzip -9 < $f > $f.gz; done").stderr.pipe stderr
    console.log 'gzipping files'.green
  generateMainSitemap: ->
    cp "#{__dirname}/main.xml", "#{folder}/main.xml"
    console.log 'copied main.xml'.green

  ls: ls
  cp: cp
