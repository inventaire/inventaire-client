#!/usr/bin/env coffee

CONFIG = require 'config'
__ = CONFIG.universalPath

# Avoid to use server-side modules, as it makes executing this script
# depend on the server side repository having run 'npm install'
# which might not be the case. Ex: client-only development environment
{ omit } = require 'lodash'
{ green, red } = require 'chalk'

fs = require 'fs'
{ promisify } = require 'util'
readFile = promisify fs.readFile
writeFile = promisify fs.writeFile

convertMarkdown = require './lib/convert_markdown'

{ parse: papaparse } = require 'papaparse'

csvFile = __.path 'client', 'scripts/assets/mentions.csv'
jsonFile = __.path 'client', 'public/json/mentions.json'

cleanAttributes = (obj)->
  for k, v of obj
    if v is '' then delete obj[k]

  return obj

mentions = {}

readFile csvFile, { encoding: 'utf-8' }
.then (file)->
  { data } = papaparse file, { header: true }
  data
  .map cleanAttributes
  .filter (el)-> el.type?
  .forEach (el)->
    { type, lang } = el
    # convert type to plural form
    type += 's'
    el.text = convertMarkdown el.text
    mentions[type] or= {}
    mentions[type][lang] or= []
    mentions[type][lang].push omit(el, ['type'])

  console.log 'mentions', mentions

  updatedFile = JSON.stringify mentions

  writeFile jsonFile, updatedFile
  .then -> console.log green('done!')
  .catch console.error.bind(console, red('build mentions'))
