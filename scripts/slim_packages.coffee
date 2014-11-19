#!/usr/bin/env coffee
fs = require 'fs'
ls = require 'ls'

# to be fired at project root
packages = ls( process.cwd() + '/node_modules/**/package.json').map (res)-> res.full

fieldsToKeep = [
  'name'
  'version'
  'main'
  'dependencies'
  'browser'
  'repository'
  'scripts'
]

packages.forEach (file)->

  fs.readFile file, (err, body)->
    pack = JSON.parse body.toString()
    name = pack.name

    slim = {}
    fieldsToKeep.forEach (fieldName)->
      value = pack[fieldName]
      if value? then slim[fieldName] = value

    console.log "slim #{name} package: \n", slim
    updatedJson = JSON.stringify slim, null, 4

    fs.writeFile file, updatedJson, (err, body)->
      if err?
        console.error('err', err)
      else
        console.log "slimed #{name} package.json\n"