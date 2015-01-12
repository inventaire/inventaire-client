#!/usr/bin/env coffee
json_  = require './lib/json'
__ = require './lib/paths'

console.log process.cwd()

path = '../public/i18n/src/wikidata/properties_list'
console.log path
propertiesList = require(path)

json_.read __.src.wikidata 'en-all'
.then (allEnProps)->
  enProps = {}
  propertiesList.forEach (P)->
    console.log P, enProps[P] = allEnProps[P]

  json_.write __.src.wikidata('en'), enProps

.catch (err)-> console.log 'allEnProps err', err