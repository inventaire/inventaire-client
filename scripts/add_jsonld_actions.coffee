#!/usr/bin/env coffee
addText = require './lib/add_text.coffee'
minifyJson = (jsonString)-> JSON.stringify JSON.parse(jsonString)

addText
  filename: 'actions.jsonld'
  marker: 'ACTIONS'
  modifier: minifyJson
