#!/usr/bin/env coffee
fs = require 'graceful-fs'
ls = require 'ls'
require 'colors'

# to be fired at project root
packages = ls( process.cwd() + '/node_modules/level**/package.json').map (res)-> res.full

fieldsToKeep = [
  'name'
  'version'
  'main'
  'dependencies'
  'browser'
  'repository'
  'scripts'
]

for file in packages

  fs.readFile file, (err, body)->
    pack = JSON.parse body.toString()
    name = pack.name

    slim = {}
    for fieldName in fieldsToKeep
      value = pack[fieldName]
      if value? then slim[fieldName] = value

    console.log "slim #{name} package: \n"
    updatedJson = JSON.stringify slim, null, 4

    fs.writeFile file, updatedJson, (err, body)->
      if err?
        console.error('err'.red, err)
      else
        console.log "slimed #{name} package.json\n".green