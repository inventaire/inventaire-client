#!/usr/bin/env coffee
json_  = require './lib/json'
__ = require './lib/paths'

path = '../public/i18n/src/wikidata/properties_list'
propertiesList = require(path)

json_.read __.src.wikidata 'en-all'
.then (allEnProps)->
  enProps = {}
  for property in propertiesList
    enProps[property] = allEnProps[property]
    # console.log property, enProps[property]

  json_.write __.src.wikidata('en'), enProps

.catch (err)-> console.log 'allEnProps err', err
