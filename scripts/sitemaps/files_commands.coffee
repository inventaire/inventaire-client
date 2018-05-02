{ folder } = require './config'
{ exec } = require 'child_process'
{ grey, green } = require 'chalk'

fs = require 'fs'
ls = (dir)-> console.log fs.readdirSync(dir)
cp = (orignal, copy)->
  fs.createReadStream orignal
  .pipe fs.createWriteStream(copy)

{ stderr } = process

module.exports =
  rmFiles: ->
    exec("rm #{folder}/*").stderr.pipe stderr
    console.log grey('removed old files')
  gzipFiles: ->
    exec("for f in #{folder}/*; do gzip --best < $f > $f.gz; done").stderr.pipe stderr
    console.log green('gzipping files')
  generateMainSitemap: ->
    cp "#{__dirname}/main.xml", "#{folder}/main.xml"
    console.log green('copied main.xml')

  ls: ls
  cp: cp
